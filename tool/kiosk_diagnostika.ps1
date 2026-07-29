# Info Kiosk - tarmoq diagnostikasi
#
# Kioskda "Server bilan bog'lanib bo'lmadi" yozuvi chiqsa shu skriptni ishga
# tushiring. U sababni topib, xulosa chiqaradi.
#
# Ishga tushirish (PowerShell):
#     powershell -ExecutionPolicy Bypass -File kiosk_diagnostika.ps1
#
# Natijani to'liq nusxalab yuboring.
#
# Fayl ataylab sof ASCII: kiosk Windows'i har xil kodlashda bo'lishi mumkin,
# lotin apostrofidan boshqa maxsus belgi ishlatilmaydi.

$ErrorActionPreference = 'Continue'
$srv = 'qabulxona.gennis.uz'
$url = "https://$srv/api/kiosk/info/sections?lang=all"
$muammolar = @()

Write-Host ''
Write-Host '=======================================================' -ForegroundColor Cyan
Write-Host '  INFO KIOSK - TARMOQ DIAGNOSTIKASI' -ForegroundColor Cyan
Write-Host '=======================================================' -ForegroundColor Cyan
Write-Host ''

# --- 1. Soat va sana --------------------------------------------------------
# Soat noto'g'ri bo'lsa HTTPS sertifikati rad etiladi va HAMMA so'rov yiqiladi.
# Kiosk temirida (o'lgan CMOS batareyasi) eng ko'p uchraydigan sabab.
Write-Host '[1] Soat va sana' -ForegroundColor Yellow
Write-Host ('    Kompyuter vaqti : ' + (Get-Date))
Write-Host ('    Vaqt mintaqasi  : ' + (Get-TimeZone).Id)
try {
    $resp = Invoke-WebRequest 'http://www.msftconnecttest.com/connecttest.txt' -UseBasicParsing -TimeoutSec 10
    $web = [DateTime]::Parse($resp.Headers['Date'])
    $farq = [math]::Abs(((Get-Date).ToUniversalTime() - $web.ToUniversalTime()).TotalMinutes)
    Write-Host ('    Haqiqiy vaqtdan farq: ' + [math]::Round($farq, 1) + ' daqiqa')
    if ($farq -gt 10) {
        Write-Host '    XATO: soat juda katta farq qilyapti' -ForegroundColor Red
        $muammolar += ('SOAT NOTOGRI (' + [math]::Round($farq) + ' daqiqa farq) - HTTPS sertifikati shu sababli rad etiladi')
    } else {
        Write-Host '    OK' -ForegroundColor Green
    }
} catch {
    Write-Host '    (tekshirib bolmadi - internet yoq bolishi mumkin)' -ForegroundColor DarkYellow
}
Write-Host ''

# --- 2. DNS -----------------------------------------------------------------
Write-Host '[2] Domen nomi - DNS' -ForegroundColor Yellow
try {
    $dns = Resolve-DnsName $srv -Type A -ErrorAction Stop | Where-Object { $_.IPAddress } | Select-Object -First 1
    Write-Host ('    ' + $srv + ' -> ' + $dns.IPAddress)
    Write-Host '    OK' -ForegroundColor Green
} catch {
    Write-Host ('    XATO: ' + $_.Exception.Message) -ForegroundColor Red
    $muammolar += 'DNS ISHLAMAYAPTI - kiosk domen nomini aniqlay olmayapti (internet yoki DNS sozlamasi)'
}
Write-Host ''

# --- 3. 443-port ------------------------------------------------------------
Write-Host '[3] Serverga ulanish - 443-port' -ForegroundColor Yellow
try {
    $tcp = Test-NetConnection $srv -Port 443 -WarningAction SilentlyContinue
    if ($tcp.TcpTestSucceeded) {
        Write-Host '    OK - port ochiq' -ForegroundColor Green
    } else {
        Write-Host '    XATO: 443-portga ulanib bolmadi' -ForegroundColor Red
        $muammolar += '443-PORT YOPIQ - firewall yoki tarmoq chiqishni bloklayapti'
    }
} catch {
    Write-Host ('    XATO: ' + $_.Exception.Message) -ForegroundColor Red
    $muammolar += 'TARMOQQA ULANIB BOLMADI'
}
Write-Host ''

# --- 4. Proxy ---------------------------------------------------------------
Write-Host '[4] Proxy sozlamalari' -ForegroundColor Yellow
$winhttp = (netsh winhttp show proxy 2>&1 | Out-String).Trim()
# netsh matni Windows tiliga qarab o'zgaradi: inglizcha "Direct access",
# ruscha "Прямой доступ". Ikkalasini ham taniymiz, aks holda ruscha
# Windows'da proxy yo'q bo'lsa ham "proxy bor" deb noto'g'ri ogohlantiradi.
if ($winhttp -match 'Direct access' -or $winhttp -match [char]0x041F + '.*' + [char]0x0434 + [char]0x043E + [char]0x0441 + [char]0x0442 + [char]0x0443 + [char]0x043F) {
    Write-Host '    WinHTTP: proxy yoq (togridan-togri)' -ForegroundColor Green
} else {
    Write-Host ('    WinHTTP: ' + $winhttp) -ForegroundColor DarkYellow
    $muammolar += 'PROXY SOZLANGAN - ilova proxy ishlatmaydi, shuning uchun ulanolmasligi mumkin'
}
Write-Host ''

# --- 5. API so'rovi ---------------------------------------------------------
# Eng muhimi: ilova aynan shu so'rovni yuboradi.
Write-Host '[5] API sorovi - ilova aynan shuni yuboradi' -ForegroundColor Yellow
Write-Host ('    ' + $url)
try {
    $r = Invoke-WebRequest $url -UseBasicParsing -TimeoutSec 25
    Write-Host ('    HTTP ' + $r.StatusCode + ' - ' + [math]::Round($r.RawContentLength / 1KB, 1) + ' KB') -ForegroundColor Green
    if ($r.Content -match '"data":null') {
        Write-Host '    DIQQAT: server javob berdi, lekin bolim bosh' -ForegroundColor DarkYellow
        $muammolar += 'SERVER JAVOB BERYAPTI, lekin bolim bosh - bu tarmoq emas, kontent muammosi'
    } else {
        Write-Host '    OK - malumot keldi' -ForegroundColor Green
    }
} catch {
    $msg = $_.Exception.Message
    Write-Host ('    XATO: ' + $msg) -ForegroundColor Red
    if ($msg -match 'SSL|TLS|trust|secure channel') {
        $muammolar += 'HTTPS/SERTIFIKAT XATOSI - soatni va Windows yangilanishlarini tekshiring'
    } elseif ($msg -match 'timed out') {
        $muammolar += 'SOROV VAQTI TUGADI - tarmoq juda sekin yoki bloklangan'
    } else {
        $muammolar += ('API SOROVI YIQILDI: ' + $msg)
    }
}
Write-Host ''

# --- 6. Ilovaning o'z logi --------------------------------------------------
Write-Host '[6] Ilova logi' -ForegroundColor Yellow
$log = Join-Path $env:LOCALAPPDATA 'info_kiosk\content\log.txt'
if (Test-Path $log) {
    Write-Host ('    ' + $log)
    Get-Content $log -Tail 10 | ForEach-Object { Write-Host ('    ' + $_) -ForegroundColor DarkGray }
} else {
    Write-Host '    Log fayl yoq - ilova hali ishga tushmagan yoki xato bolmagan'
}
Write-Host ''

# --- 7. Saqlangan nusxa -----------------------------------------------------
Write-Host '[7] Saqlangan malumot - kesh' -ForegroundColor Yellow
$cache = Join-Path $env:LOCALAPPDATA 'info_kiosk\content'
if (Test-Path $cache) {
    $files = @(Get-ChildItem $cache -Filter '*.json' -ErrorAction SilentlyContinue)
    Write-Host ('    ' + $files.Count + ' ta bolim saqlangan')
} else {
    Write-Host '    Kesh yoq - ilova hali bir marta ham malumot ololmagan'
}
Write-Host ''

# --- Xulosa -----------------------------------------------------------------
Write-Host '=======================================================' -ForegroundColor Cyan
Write-Host '  XULOSA' -ForegroundColor Cyan
Write-Host '=======================================================' -ForegroundColor Cyan
if ($muammolar.Count -eq 0) {
    Write-Host '  Muammo topilmadi - tarmoq va server joyida.' -ForegroundColor Green
    Write-Host '  Ilovani qayta ishga tushiring.' -ForegroundColor Green
} else {
    foreach ($m in $muammolar) { Write-Host ('  * ' + $m) -ForegroundColor Red }
}
Write-Host ''
Write-Host '  Shu natijani toliq nusxalab yuboring.'
Write-Host ''
