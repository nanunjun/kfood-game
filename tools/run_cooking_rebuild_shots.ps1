# P1 Cooking Rebuild — render the 6 module verification shots (real opengl3 viewport),
# then copy the PNGs out of user:// into assets-raw/_screenshots/cooking_rebuild/.
# Usage: powershell -File tools/run_cooking_rebuild_shots.ps1 [before|after]
param([string]$Tag = "after")

$godot   = Join-Path ([Environment]::GetFolderPath("UserProfile")) "Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64.exe"
$proj    = "C:\Projects\kfood-game\godot-project"
$userdir = "C:\Users\JS Park\AppData\Roaming\Godot\app_userdata\K-Food Master\cooking_rebuild"
$dest    = "C:\Projects\kfood-game\assets-raw\_screenshots\cooking_rebuild"
$out     = "C:\Projects\kfood-game\tools\cooking_rebuild_out.txt"

if (-not (Test-Path -LiteralPath $godot)) { Write-Error "Godot not found at $godot"; exit 1 }
New-Item -ItemType Directory -Force -Path $dest | Out-Null

$env:KFOOD_CR_TAG = $Tag

& $godot --path $proj --rendering-driver opengl3 --resolution 540x960 --quit-after 16000 "res://scenes/shot_cooking_rebuild.tscn" *>&1 | Out-File -FilePath $out -Encoding utf8
"EXIT=$LASTEXITCODE" | Out-File -FilePath $out -Append -Encoding utf8

# Copy generated *_<tag>.png from user:// to the repo screenshot dir.
Get-ChildItem $userdir -Filter "*_$Tag.png" -ErrorAction SilentlyContinue | ForEach-Object {
  Copy-Item $_.FullName (Join-Path $dest $_.Name) -Force
  Write-Output ("copied " + $_.Name)
}

Write-Output "----- godot log (tail) -----"
Get-Content $out -Tail 30
