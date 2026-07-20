import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../l10n.dart';

enum SpeechEventType { finalResult, noSpeech, speakDone }

class SpeechEvent {
  const SpeechEvent(this.type, [this.text = '']);
  final SpeechEventType type;
  final String text;
}

/// Bridges to Windows' built-in, fully offline speech stack (SAPI via
/// System.Speech) through a persistent hidden PowerShell helper process —
/// no network and no extra plugins, in keeping with the self-contained kiosk.
///
/// Protocol (line-based over stdin/stdout, payloads base64-encoded so any
/// alphabet survives the pipe):
///   in:  `LISTEN` | `VOICE <culture-prefix>` | `SPEAK <b64 text>` | `QUIT`
///   out: `RECOK` | `TTSOK` | `READY` | `FINAL:<b64 text>` | `NOSPEECH` | `SPEAKDONE`
class SpeechService {
  Process? _proc;
  bool recognitionAvailable = false;
  bool ttsAvailable = false;
  bool initialized = false;
  bool _ready = false;

  final StreamController<SpeechEvent> _events = StreamController.broadcast();
  Stream<SpeechEvent> get events => _events.stream;

  static const String _script = r'''
$ErrorActionPreference = 'Continue'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}
$out = [Console]::Out
$rec = $null
$synth = $null
try { Add-Type -AssemblyName System.Speech } catch { $out.WriteLine('READY'); exit }
try {
  $rec = New-Object System.Speech.Recognition.SpeechRecognitionEngine
  $rec.LoadGrammar((New-Object System.Speech.Recognition.DictationGrammar))
  $rec.SetInputToDefaultAudioDevice()
  $rec.EndSilenceTimeout = [TimeSpan]::FromMilliseconds(900)
  $out.WriteLine('RECOK')
} catch { $rec = $null }
try {
  $synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
  $synth.SetOutputToDefaultAudioDevice()
  $out.WriteLine('TTSOK')
} catch { $synth = $null }
$out.WriteLine('READY')

while ($true) {
  $line = [Console]::In.ReadLine()
  if ($null -eq $line -or $line -eq 'QUIT') { break }
  if ($line -eq 'LISTEN') {
    if ($null -eq $rec) { $out.WriteLine('NOSPEECH'); continue }
    try {
      $r = $rec.Recognize([TimeSpan]::FromSeconds(8))
      if ($null -ne $r -and $r.Text) {
        $b = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($r.Text))
        $out.WriteLine('FINAL:' + $b)
      } else { $out.WriteLine('NOSPEECH') }
    } catch { $out.WriteLine('NOSPEECH') }
    continue
  }
  if ($line.StartsWith('VOICE ')) {
    if ($null -ne $synth) {
      $hint = $line.Substring(6)
      try {
        $v = $synth.GetInstalledVoices() |
          Where-Object { $_.Enabled -and $_.VoiceInfo.Culture.Name.StartsWith($hint) } |
          Select-Object -First 1
        if ($v) { $synth.SelectVoice($v.VoiceInfo.Name) }
      } catch {}
    }
    continue
  }
  if ($line.StartsWith('SPEAK ')) {
    if ($null -ne $synth) {
      try {
        $text = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($line.Substring(6)))
        $synth.Speak($text)
      } catch {}
    }
    $out.WriteLine('SPEAKDONE')
    continue
  }
}
''';

  Future<void> init() async {
    if (!Platform.isWindows || _proc != null) {
      initialized = true;
      return;
    }
    try {
      final file = File('${Directory.systemTemp.path}/kiosk_ai_speech.ps1');
      await file.writeAsString(_script);
      final p = await Process.start('powershell.exe', [
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-WindowStyle',
        'Hidden',
        '-File',
        file.path,
      ]);
      _proc = p;
      p.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(_onLine, onDone: _onExit);
      unawaited(p.stderr.drain<void>());

      final t0 = DateTime.now();
      while (!_ready && DateTime.now().difference(t0).inSeconds < 8) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    } catch (_) {
      _proc = null;
    }
    initialized = true;
  }

  void _onLine(String line) {
    if (line == 'READY') {
      _ready = true;
    } else if (line == 'RECOK') {
      recognitionAvailable = true;
    } else if (line == 'TTSOK') {
      ttsAvailable = true;
    } else if (line.startsWith('FINAL:')) {
      final text = _b64d(line.substring(6)).trim();
      _events.add(text.isEmpty
          ? const SpeechEvent(SpeechEventType.noSpeech)
          : SpeechEvent(SpeechEventType.finalResult, text));
    } else if (line == 'NOSPEECH') {
      _events.add(const SpeechEvent(SpeechEventType.noSpeech));
    } else if (line == 'SPEAKDONE') {
      _events.add(const SpeechEvent(SpeechEventType.speakDone));
    }
  }

  void _onExit() {
    recognitionAvailable = false;
    ttsAvailable = false;
    _proc = null;
  }

  void _send(String cmd) {
    try {
      _proc?.stdin.writeln(cmd);
    } catch (_) {}
  }

  static String _b64(String s) => base64Encode(utf8.encode(s));

  static String _b64d(String s) {
    try {
      return utf8.decode(base64Decode(s));
    } catch (_) {
      return '';
    }
  }

  /// Capture one utterance from the default microphone.
  void listen() => _send('LISTEN');

  /// Read [text] aloud, preferring an installed voice close to [lang].
  /// (Uzbek voices don't ship with SAPI, so Latin-script Uzbek falls back to
  /// an English voice, Russian to a Russian one when installed.)
  void speak(String text, Lang lang) {
    _send('VOICE ${lang == Lang.ru ? 'ru' : 'en'}');
    _send('SPEAK ${_b64(text.replaceAll('\n', ' '))}');
  }

  void dispose() {
    _send('QUIT');
    _proc?.kill();
    _proc = null;
    _events.close();
  }
}
