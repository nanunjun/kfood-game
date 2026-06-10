# run_godot.ps1 — Godot 4.6.3 invocation helper (local dev).
# Usage: powershell -NoProfile -File tools/run_godot.ps1 <godot args...>
$ErrorActionPreference = "Stop"
$godot = (Join-Path ([Environment]::GetFolderPath("UserProfile")) "Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64_console.exe")
if (-not (Test-Path -LiteralPath $godot)) {
	Write-Error "Godot not found at $godot"
	exit 1
}
& $godot @args
exit $LASTEXITCODE
