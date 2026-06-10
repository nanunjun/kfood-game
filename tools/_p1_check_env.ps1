# P1 env check — confirm Godot exe + userdir.
$godot = Join-Path ([Environment]::GetFolderPath("UserProfile")) "Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64.exe"
if (Test-Path -LiteralPath $godot) { Write-Output "FOUND: $godot" } else { Write-Output "MISSING godot" }
$u = "C:\Users\JS Park\AppData\Roaming\Godot\app_userdata\K-Food Master"
if (Test-Path -LiteralPath $u) { Write-Output "USERDIR OK" } else { Write-Output "USERDIR MISSING" }
