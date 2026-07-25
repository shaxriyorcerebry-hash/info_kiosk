import 'dart:convert';
import 'dart:io';

/// Hand the machine back to the normal Windows desktop before the kiosk quits.
///
/// Three things have to happen for staff to land on a usable desktop:
///
/// 1. The shell must be running. A kiosk machine often has this app registered
///    as the shell in place of Explorer, so quitting would leave a bare screen.
///    Explorer is restarted only when the shell really is gone, so a normal
///    machine does not get a stray File Explorer folder on exit.
/// 2. The task bar and desktop icons must be visible. When Explorer does run,
///    kiosk setups hide those windows instead — so they are un-hidden here.
/// 3. Anything still on screen must get out of the way, which is what the
///    final "minimise all" does (the same thing Win+D does).
///
/// Window classes: `Shell_TrayWnd` is the primary task bar,
/// `Shell_SecondaryTrayWnd` the copies on additional monitors, `Button`/`Start`
/// the old Start orb, and `Progman` + `SHELLDLL_DefView` the desktop icons.
const String _restoreShellScript = r'''
$ErrorActionPreference = 'SilentlyContinue'
$sig = @'
[DllImport("user32.dll", CharSet=CharSet.Auto)] public static extern IntPtr FindWindow(string lpClass, string lpWindow);
[DllImport("user32.dll", CharSet=CharSet.Auto)] public static extern IntPtr FindWindowEx(IntPtr parent, IntPtr after, string lpClass, string lpWindow);
[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
'@
$u = Add-Type -MemberDefinition $sig -Name Shell -Namespace Kiosk -PassThru
$tray = $u::FindWindow('Shell_TrayWnd', $null)
if ($tray -eq [IntPtr]::Zero) {
  # No shell at all: Explorer brings back the task bar and the desktop itself.
  Start-Process explorer.exe
  exit 0
}
$u::ShowWindow($tray, 5) | Out-Null
$orb = $u::FindWindow('Button', 'Start')
if ($orb -ne [IntPtr]::Zero) { $u::ShowWindow($orb, 5) | Out-Null }
$next = [IntPtr]::Zero
while ($true) {
  $next = $u::FindWindowEx([IntPtr]::Zero, $next, 'Shell_SecondaryTrayWnd', $null)
  if ($next -eq [IntPtr]::Zero) { break }
  $u::ShowWindow($next, 5) | Out-Null
}
# Desktop icons: Progman normally hosts them, but after a wallpaper slideshow
# they live in a WorkerW instead, so both are checked.
$prog = $u::FindWindow('Progman', $null)
if ($prog -ne [IntPtr]::Zero) {
  $u::ShowWindow($prog, 5) | Out-Null
  $view = $u::FindWindowEx($prog, [IntPtr]::Zero, 'SHELLDLL_DefView', $null)
  if ($view -ne [IntPtr]::Zero) { $u::ShowWindow($view, 5) | Out-Null }
}
$worker = [IntPtr]::Zero
while ($true) {
  $worker = $u::FindWindowEx([IntPtr]::Zero, $worker, 'WorkerW', $null)
  if ($worker -eq [IntPtr]::Zero) { break }
  $view = $u::FindWindowEx($worker, [IntPtr]::Zero, 'SHELLDLL_DefView', $null)
  if ($view -ne [IntPtr]::Zero) {
    $u::ShowWindow($worker, 5) | Out-Null
    $u::ShowWindow($view, 5) | Out-Null
  }
}
# Clear everything else off the screen, exactly like Win+D.
(New-Object -ComObject Shell.Application).MinimizeAll()
exit 0
''';

/// Restore the task bar / desktop shell. Never throws: failing to bring the
/// shell back must not keep staff trapped inside the kiosk.
Future<void> restoreWindowsShell() async {
  if (!Platform.isWindows) return;
  try {
    final result = await Process.run('powershell.exe', [
      '-NoProfile',
      '-NonInteractive',
      '-WindowStyle',
      'Hidden',
      '-EncodedCommand',
      base64.encode(_utf16le(_restoreShellScript)),
    ]).timeout(const Duration(seconds: 15));
    if (result.exitCode == 0) return;
  } catch (_) {
    // PowerShell missing, blocked by policy or too slow — fall through.
  }
  // Last resort: start Explorer directly. Harmless if it is already the shell
  // (it then just opens a folder window), and it is the only way back to a
  // task bar when the script could not run at all.
  try {
    await Process.start(
      'explorer.exe',
      const [],
      mode: ProcessStartMode.detached,
    );
  } catch (_) {
    // Nothing more we can do; leaving the kiosk still proceeds.
  }
}

/// PowerShell's `-EncodedCommand` expects base64 of UTF-16LE, which sidesteps
/// every quoting problem in passing a multi-line script as one argument.
List<int> _utf16le(String script) {
  final bytes = <int>[];
  for (final unit in script.codeUnits) {
    bytes.add(unit & 0xff);
    bytes.add(unit >> 8);
  }
  return bytes;
}
