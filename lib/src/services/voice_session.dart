import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_windows/webview_windows.dart';

import 'ai_api.dart';

/// What the live voice page reports back to Flutter.
enum VoiceEventType {
  /// Session phase: connecting / listening / speaking / closed.
  state,

  /// A finished question, transcribed from the visitor's speech.
  question,

  /// A finished answer, transcribed from what the advisor said aloud.
  answer,

  /// The session failed; the caller falls back to the offline bridge.
  error,
}

class VoiceEvent {
  const VoiceEvent(this.type, this.value);
  final VoiceEventType type;
  final String value;
}

/// Runs a Gemini Live conversation inside an off-screen Edge WebView2.
///
/// Flutter Windows can neither open the microphone nor play a raw PCM stream,
/// but a browser engine does both natively, so the audio pipeline
/// (mic → Gemini → speakers) lives in JavaScript and only *events* cross into
/// Dart. This is the same approach the avatar kiosk uses; here it carries no
/// 3D scene — just voice plus transcripts, which the AI screen shows as text.
///
/// The page is served from a temp directory through a WebView2 *virtual host*
/// rather than a `file://` URL. That detail is load-bearing: only a secure
/// origin may open the microphone or load an ES module, so `file://` fails at
/// both. The Gemini SDK is bundled as an asset, so nothing is fetched from a
/// CDN — the page's only outbound connection is the live session itself.
///
/// Everything here is best-effort: if WebView2 is missing, the microphone is
/// refused or the session drops, [available] stays false / an error event is
/// emitted and the kiosk keeps working through the offline SAPI bridge.
class VoiceSession {
  /// Virtual host the page is served from — an invented name, never resolved
  /// over DNS; WebView2 maps it straight to the local directory.
  static const String _host = 'kiosk-voice.local';

  final WebviewController controller = WebviewController();

  final StreamController<VoiceEvent> _events = StreamController.broadcast();
  Stream<VoiceEvent> get events => _events.stream;

  StreamSubscription<dynamic>? _msgSub;

  /// True once the WebView2 page is loaded and `startVoice` can be called.
  bool available = false;

  /// True between [start] and [stop] — a live session is (or is becoming) up.
  bool running = false;

  /// Prepares the browser engine and loads the voice page. Never throws:
  /// returns false when WebView2 is unavailable on this machine.
  Future<bool> init() async {
    try {
      final dir = await _extractPage();
      // The advisor greets the visitor on its own, so playback must not wait
      // for a gesture inside the page (the visitor's tap happens in Flutter).
      try {
        await WebviewController.initializeEnvironment(
          additionalArguments: '--autoplay-policy=no-user-gesture-required',
        );
      } catch (_) {
        // Already initialised by an earlier call — that is fine.
      }
      await controller.initialize();
      await controller.setBackgroundColor(const Color(0x00000000));
      // Serve the page from a virtual https host: a secure origin is what
      // makes getUserMedia and the ES module import legal.
      await controller.addVirtualHostNameMapping(
        _host,
        dir.path,
        WebviewHostResourceAccessKind.allow,
      );
      _msgSub = controller.webMessage.listen(_onMessage);
      await controller.loadUrl('https://$_host/voice.html');
      available = true;
      return true;
    } catch (e) {
      debugPrint('voice session unavailable (WebView2?): $e');
      trace('init failed: $e');
      available = false;
      return false;
    }
  }

  /// Appends a line to `%TEMP%\info_kiosk_voice.log`.
  ///
  /// A kiosk runs with no console and nobody watching it, so a voice failure
  /// out in the field is otherwise invisible — this file is what staff can
  /// send back when the advisor stops answering. Best-effort and tiny: only
  /// failures are written, never a working session's chatter.
  void trace(String line) {
    try {
      File('${Directory.systemTemp.path}/info_kiosk_voice.log').writeAsStringSync(
        '${DateTime.now().toIso8601String()}  $line\n',
        mode: FileMode.append,
        flush: true,
      );
    } catch (_) {
      // Read-only temp or a locked file — diagnostics are never worth a crash.
    }
  }

  /// Opens a live session with [token]. The visitor may then simply speak;
  /// Gemini's own voice-activity detection decides when a question ended.
  Future<void> start(VoiceToken token, {String greeting = ''}) async {
    if (!available || running) return;
    running = true;
    final cfg = jsonEncode({
      'token': token.token,
      'model': token.model,
      'voice': token.voice,
      'language': token.language,
      'greeting': greeting,
    });
    await controller.executeScript('window.startVoice($cfg)');
  }

  Future<void> stop() async {
    if (!available || !running) return;
    running = false;
    await controller.executeScript('window.stopVoice()');
  }

  void _onMessage(dynamic raw) {
    Map<String, dynamic>? msg;
    if (raw is Map) {
      msg = raw.cast<String, dynamic>();
    } else if (raw is String) {
      try {
        msg = (jsonDecode(raw) as Map).cast<String, dynamic>();
      } catch (_) {
        return;
      }
    }
    if (msg == null) return;
    final text = msg['text']?.toString() ?? msg['message']?.toString() ?? '';
    switch (msg['type']) {
      case 'state':
        _emit(VoiceEventType.state, msg['value']?.toString() ?? '');
      case 'user':
        _emit(VoiceEventType.question, text);
      case 'ai':
        _emit(VoiceEventType.answer, text);
      case 'error':
        debugPrint('voice JS error: $text');
        trace('js error: $text');
        _emit(VoiceEventType.error, text);
      case 'log':
        debugPrint('voice JS: $text');
    }
  }

  void _emit(VoiceEventType t, String v) {
    // The server can end a session on its own. Clearing [running] on every
    // route into here — page message or test — is what lets the next tap open
    // a fresh session instead of trying to stop one that is already gone.
    if (t == VoiceEventType.error || (t == VoiceEventType.state && v == 'closed')) {
      running = false;
    }
    if (!_events.isClosed) _events.add(VoiceEvent(t, v));
  }

  /// Pushes an event as though the voice page had posted it, so tests can
  /// drive the states a real session produces without a browser or a mic.
  @visibleForTesting
  void emit(VoiceEvent e) => _emit(e.type, e.value);

  /// Writes the page and the bundled SDK next to each other in temp.
  Future<Directory> _extractPage() async {
    final dir = Directory('${Directory.systemTemp.path}/info_kiosk_voice');
    await dir.create(recursive: true);
    final sdk = await rootBundle.load('assets/web/genai.min.js');
    await File('${dir.path}/genai.min.js').writeAsBytes(
      sdk.buffer.asUint8List(sdk.offsetInBytes, sdk.lengthInBytes),
      flush: true,
    );
    await File('${dir.path}/voice.html').writeAsString(_page, flush: true);
    return dir;
  }

  Future<void> dispose() async {
    await _msgSub?.cancel();
    await _events.close();
    if (available) await controller.dispose();
  }
}

/// The voice page: a blank document whose only job is to run the live audio
/// pipeline. Nothing here is ever seen — the kiosk UI is pure Flutter.
const String _page = r'''
<!doctype html>
<html lang="uz">
<head><meta charset="utf-8"><title>voice</title>
<style>html,body{margin:0;background:transparent}</style></head>
<body>
<script>
// Classic script, so it runs even if the module below fails to load: it proves
// the Flutter bridge is up and turns otherwise-silent page errors (a bad
// import, a syntax error) into events Dart can log.
function bridge(o){ try{ window.chrome.webview.postMessage(JSON.stringify(o)); }catch(e){} }
window.addEventListener('error', (e) =>
  bridge({type:'error', message:'page: ' + (e.message || e) + ' @' + (e.filename || '') + ':' + (e.lineno || 0)}));
window.addEventListener('unhandledrejection', (e) =>
  bridge({type:'error', message:'page reject: ' + ((e.reason && (e.reason.stack || e.reason.message)) || e.reason)}));
bridge({type:'log', message:'bridge up'});
</script>
<script type="module">
import { GoogleGenAI } from './genai.min.js';

function post(o){ try{ window.chrome.webview.postMessage(JSON.stringify(o)); }catch(e){} }
function state(v){ post({type:'state', value:v}); }
function fail(m){ post({type:'error', message:String(m)}); }
function log(m){ post({type:'log', message:String(m)}); }

let session = null, inCtx = null, micStream = null, proc = null;
let outCtx = null, outGain = null, playHead = 0, speaking = false, speakGuard = null;
let activeSrc = [];
// Transcripts arrive as fragments; they are joined per turn and posted whole.
let userBuf = '', aiBuf = '';

window.startVoice = async function(cfg){
  try {
    state('connecting');
    userBuf = ''; aiBuf = '';
    outCtx = new (window.AudioContext || window.webkitAudioContext)();
    await outCtx.resume();
    outGain = outCtx.createGain(); outGain.gain.value = 1;
    outGain.connect(outCtx.destination);
    playHead = outCtx.currentTime;

    const ai = new GoogleGenAI({ apiKey: cfg.token, httpOptions: { apiVersion: 'v1alpha' } });
    const config = {
        responseModalities: ['AUDIO'],
        // The kiosk screen shows the conversation as text, so ask the server to
        // transcribe both sides — otherwise an AUDIO session carries no words.
        inputAudioTranscription: {},
        outputAudioTranscription: {},
        // Barge-in: a visitor may cut in mid-answer and be heard. Sensitivity is
        // left at the default; HIGH proved too eager in a public space.
        realtimeInputConfig: { activityHandling: 'START_OF_ACTIVITY_INTERRUPTS' },
    };
    // No speechConfig here on purpose: the voice is baked into the ephemeral
    // token (the app asks the token endpoint for KioskConfig.aiVoice), and a
    // token's server-side choice wins over any client override anyway.
    session = await ai.live.connect({
      model: cfg.model,
      config: config,
      callbacks: {
        onopen: () => { log('live open'); state('listening'); },
        onmessage: onMessage,
        onerror: (e) => fail('live: ' + (e && (e.message || e))),
        // The close code and reason are the only thing that says WHY the
        // server dropped a session that had just opened, so never swallow them.
        onclose: (e) => {
          log('live close code=' + ((e && e.code) || '?') + ' reason=' + ((e && e.reason) || '(none)'));
          state('closed');
        },
      },
    });
    // A short, fixed opening line, spoken in the kiosk's current language.
    if (cfg.greeting) {
      try {
        session.sendClientContent({
          turns: [{ role: 'user', parts: [{ text: cfg.greeting }] }],
          turnComplete: true,
        });
      } catch(e){ log('greet ' + e); }
    }
    await startMic();
  } catch(e){ fail('startVoice: ' + (e && (e.stack || e.message || e))); }
};

window.stopVoice = function(){
  try {
    stopPlayback();
    if (proc){ proc.disconnect(); proc.onaudioprocess = null; proc = null; }
    if (inCtx){ inCtx.close(); inCtx = null; }
    if (micStream){ micStream.getTracks().forEach(t => t.stop()); micStream = null; }
    if (session){ try{ session.close(); }catch(e){} session = null; }
    if (outCtx){ outCtx.close(); outCtx = null; }
    state('closed');
  } catch(e){ log('stop ' + e); }
};

function onMessage(m){
  try {
    const sc = m && m.serverContent;
    // Audio out — prefer inlineData parts, else the m.data convenience field.
    let played = false;
    const parts = sc && sc.modelTurn && sc.modelTurn.parts;
    if (parts){ for (const p of parts){ if (p.inlineData && p.inlineData.data){ playChunk(p.inlineData.data, p.inlineData.mimeType); played = true; } } }
    if (!played && m && m.data){ playChunk(m.data, 'audio/pcm;rate=24000'); }

    if (sc && sc.inputTranscription && sc.inputTranscription.text) userBuf += sc.inputTranscription.text;
    if (sc && sc.outputTranscription && sc.outputTranscription.text) aiBuf += sc.outputTranscription.text;
    // A turn ended: hand both halves to Flutter so the screen can show them.
    if (sc && sc.turnComplete){
      if (userBuf.trim()) post({type:'user', text: userBuf.trim()});
      if (aiBuf.trim()) post({type:'ai', text: aiBuf.trim()});
      userBuf = ''; aiBuf = '';
    }
    // Barge-in: kill the old answer's audio at once.
    if (sc && sc.interrupted){ stopPlayback(); state('listening'); }
  } catch(e){ log('msg ' + e); }
}

async function startMic(){
  micStream = await navigator.mediaDevices.getUserMedia({ audio: { channelCount:1, echoCancellation:true, noiseSuppression:true, autoGainControl:true } });
  inCtx = new (window.AudioContext || window.webkitAudioContext)({ sampleRate: 16000 });
  await inCtx.resume();
  const srcNode = inCtx.createMediaStreamSource(micStream);
  // 2048 samples @16kHz = 128ms chunks: speech reaches the server promptly.
  proc = inCtx.createScriptProcessor(2048, 1, 1);
  const mute = inCtx.createGain(); mute.gain.value = 0; // never echo mic to speakers
  srcNode.connect(proc); proc.connect(mute); mute.connect(inCtx.destination);
  proc.onaudioprocess = (ev) => {
    if (!session) return;
    const f32 = ev.inputBuffer.getChannelData(0);
    try { session.sendRealtimeInput({ audio: { data: b64(floatTo16(f32)), mimeType: 'audio/pcm;rate=16000' } }); }
    catch(e){ /* transient */ }
  };
  log('mic started');
}

// ---------- audio helpers (16k in, 24k out, gapless) ----------
function floatTo16(f32){
  const i16 = new Int16Array(f32.length);
  for (let i = 0; i < f32.length; i++){ let s = Math.max(-1, Math.min(1, f32[i])); i16[i] = s < 0 ? s * 32768 : s * 32767; }
  return new Uint8Array(i16.buffer);
}
function b64(u8){ let s = ''; const CH = 0x8000; for (let i = 0; i < u8.length; i += CH){ s += String.fromCharCode.apply(null, u8.subarray(i, i + CH)); } return btoa(s); }
function fromB64(str){ const bin = atob(str); const u8 = new Uint8Array(bin.length); for (let i = 0; i < bin.length; i++) u8[i] = bin.charCodeAt(i); return u8; }
function rateOf(mimeType){ const m = /rate=(\d+)/.exec(mimeType || ''); return m ? parseInt(m[1], 10) : 24000; }

function playChunk(b64pcm, mimeType){
  try {
    if (!outCtx) return;
    const rate = rateOf(mimeType);
    const u8 = fromB64(b64pcm);
    const n = Math.floor(u8.byteLength / 2);
    if (!n) return;
    const i16 = new Int16Array(u8.buffer, u8.byteOffset, n);
    const buf = outCtx.createBuffer(1, n, rate);
    const ch = buf.getChannelData(0);
    for (let i = 0; i < n; i++) ch[i] = i16[i] / 32768;
    const src = outCtx.createBufferSource();
    src.buffer = buf; src.connect(outGain);
    const now = outCtx.currentTime;
    // A small jitter buffer ahead of the clock keeps playback smooth.
    if (playHead < now + 0.06) playHead = now + 0.06;
    src.start(playHead);
    playHead += buf.duration;
    activeSrc.push(src);
    src.onended = () => { const i = activeSrc.indexOf(src); if (i >= 0) activeSrc.splice(i, 1); };
    onSpeak();
  } catch(e){ log('play ' + e); }
}
function onSpeak(){
  if (!speaking){ speaking = true; state('speaking'); }
  clearTimeout(speakGuard);
  const ms = Math.max(150, (playHead - outCtx.currentTime) * 1000 + 150);
  speakGuard = setTimeout(() => { speaking = false; state('listening'); }, ms);
}
function stopPlayback(){
  clearTimeout(speakGuard); speaking = false;
  for (const s of activeSrc){ try { s.onended = null; s.stop(); } catch(e){} }
  activeSrc = [];
  if (outCtx) playHead = outCtx.currentTime;
}

post({type:'log', message:'voice page ready'});
</script>
</body></html>
''';
