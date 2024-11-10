# -------------------------
# Автоматичне встановлення драйверів для пристроїв з проблемами
# -------------------------
Write-Host "Пошук і встановлення драйверів для всіх пристроїв з проблемами..."
$devicesWithErrors = Get-PnpDevice -Status "Error"

if ($devicesWithErrors) {
    foreach ($device in $devicesWithErrors) {
        Write-Host "Встановлення драйвера для пристрою:" $device.FriendlyName
        $result = $device | Enable-PnpDevice -Confirm:$false -ErrorAction SilentlyContinue
        if ($result) {
            Write-Host "Драйвер для" $device.FriendlyName "успішно встановлено."
        } else {
            Write-Host "Не вдалося встановити драйвер для" $device.FriendlyName
        }
    }
} else {
    Write-Host "Всі пристрої мають встановлені драйвери."
}

# -------------------------
# Встановлення Chocolatey, якщо його ще немає
# -------------------------
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Встановлення Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# -------------------------
# Встановлення популярних програм через Chocolatey
# -------------------------
$apps = @(
    "vlc",
    "xnview",
    "qbittorrent",
    "microsoft-office-deployment",
    "7zip"
)

foreach ($app in $apps) {
    Write-Host "Встановлення $app..."
    choco install $app -y
}

Write-Host "Програми успішно встановлені."

# -------------------------
# Вимкнення телеметрії Windows
# -------------------------
Write-Host "Вимкнення телеметрії..."
$telemetryKeys = @(
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection",
    "HKCU:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
)

foreach ($key in $telemetryKeys) {
    if (!(Test-Path $key)) { New-Item -Path $key -Force | Out-Null }
    Set-ItemProperty -Path $key -Name "AllowTelemetry" -Value 0
}

# Вимкнення основних завдань телеметрії
$tasks = @(
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
    "\Microsoft\Windows\Autochk\Proxy",
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator"
)

foreach ($task in $tasks) {
    Write-Host "Вимкнення завдання телеметрії: $task"
    schtasks /Change /TN $task /Disable
}

Write-Host "Телеметрія успішно вимкнена."
Write-Host "Налаштування завершено!"
