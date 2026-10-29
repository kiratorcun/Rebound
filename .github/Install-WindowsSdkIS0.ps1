<#
.SYNOPSIS
Windows 11 SDK (10.0.22621) kurulumunu ISO dosyası üzerinden sessizce gerçekleştirir.

.DESCRIPTION
Bu betik, Microsoft'un resmi bağlantısından Windows SDK 22621 ISO dosyasını indirir,
sisteme bağlar (mount), sessiz kurulumu başlatır ve işlem bitince ISO'yu temizler.
#>

$ErrorActionPreference = 'Stop'

# Windows 11 SDK (22621) resmi ISO indirme bağlantısı
$isoUrl = "https://go.microsoft.com/fwlink/?linkid=2196127"
$isoPath = "$env:TEMP\WindowsSDK_22621.iso"
$logPath = "$env:TEMP\winsdk_iso_install.log"

Write-Host "Windows 11 SDK (22621) ISO dosyası indiriliyor. Lütfen bekleyin..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $isoUrl -OutFile $isoPath -UseBasicParsing

Write-Host "ISO dosyası sisteme bağlanıyor (Mount)..." -ForegroundColor Cyan
$mountResult = Mount-DiskImage -ImagePath $isoPath -PassThru
$driveLetter = ($mountResult | Get-Volume).DriveLetter

if (-not $driveLetter) {
    Write-Error "ISO dosyası bağlanamadı."
    exit 1
}

$installerPath = "${driveLetter}:\winsdksetup.exe"

Write-Host "Windows SDK sessiz modda kuruluyor. Bu işlem birkaç dakika sürebilir..." -ForegroundColor Cyan
$installArgs = "/features + /q /ceip off /norestart /log `"$logPath`""

$process = Start-Process -FilePath $installerPath -ArgumentList $installArgs -Wait -PassThru

if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
    Write-Host "Windows SDK kurulumu başarıyla tamamlandı!" -ForegroundColor Green
} else {
    Write-Host "Kurulum tamamlandı fakat uyarı/hata kodu döndü. (Çıkış Kodu: $($process.ExitCode))" -ForegroundColor Yellow
    Write-Host "Detaylar için log dosyasını inceleyin: $logPath" -ForegroundColor Yellow
}

Write-Host "ISO dosyası çıkartılıyor (Dismount)..." -ForegroundColor Cyan
Dismount-DiskImage -ImagePath $isoPath | Out-Null

Write-Host "İndirilen geçici ISO dosyası siliniyor..." -ForegroundColor Cyan
Remove-Item -Path $isoPath -Force

Write-Host "Tüm işlemler tamamlandı!" -ForegroundColor Green
