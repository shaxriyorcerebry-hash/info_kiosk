$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$lat = 41.0245810; $lon = 69.3455854; $zoom = 15
$n = [math]::Pow(2, $zoom)
$xf = ($lon + 180.0) / 360.0 * $n
$latRad = $lat * [math]::PI / 180.0
$yf = (1.0 - [math]::Log([math]::Tan($latRad) + 1.0 / [math]::Cos($latRad)) / [math]::PI) / 2.0 * $n

$cx = [math]::Floor($xf); $cy = [math]::Floor($yf)
$x0 = $cx - 2; $y0 = $cy - 1   # 5x3 tile grid -> 1280x768
$w = 5 * 256; $h = 3 * 256

$bmp = New-Object System.Drawing.Bitmap($w, $h)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$tmp = "$env:TEMP\osm_tile.png"
for ($dx = 0; $dx -lt 5; $dx++) {
  for ($dy = 0; $dy -lt 3; $dy++) {
    $tx = $x0 + $dx; $ty = $y0 + $dy
    $url = "https://tile.openstreetmap.org/$zoom/$tx/$ty.png"
    Invoke-WebRequest -Uri $url -OutFile $tmp -UserAgent "info-kiosk-build/1.0 (one-time asset fetch)" | Out-Null
    $img = [System.Drawing.Image]::FromFile($tmp)
    $g.DrawImage($img, $dx * 256, $dy * 256, 256, 256)
    $img.Dispose()
    Start-Sleep -Milliseconds 150
  }
}
$g.Dispose()
$out = "C:\flutter_projects\info_kiosk\assets\images\office_map.png"
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()

$fx = ($xf - $x0) * 256 / $w
$fy = ($yf - $y0) * 256 / $h
Write-Output ("saved $out  pinX={0:F4} pinY={1:F4}" -f $fx, $fy)
