# Render the Slice knife-scale + Ramyeon season vessel-tint fix verification shots
# (real opengl3 viewport) then copy the PNGs out of user:// into
# assets-raw/_screenshots/slice_season_fix/.
$godot   = Join-Path ([Environment]::GetFolderPath("UserProfile")) "Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64.exe"
$proj    = "C:\Projects\kfood-game\godot-project"
$userdir = "C:\Users\JS Park\AppData\Roaming\Godot\app_userdata\K-Food Master"
$dest    = "C:\Projects\kfood-game\assets-raw\_screenshots\slice_season_fix"
$out     = "C:\Projects\kfood-game\tools\slice_season_fix_out.txt"

if (-not (Test-Path -LiteralPath $godot)) { Write-Error "Godot not found at $godot"; exit 1 }
New-Item -ItemType Directory -Force -Path $dest | Out-Null

& $godot --path $proj --rendering-driver opengl3 --resolution 540x960 --quit-after 2200 "res://scenes/shot_slice_season_fix.tscn" *>&1 | Out-File -FilePath $out -Encoding utf8
"EXIT=$LASTEXITCODE" | Out-File -FilePath $out -Append -Encoding utf8

# Copy generated fix_*.png from user:// to the repo screenshot dir.
Get-ChildItem $userdir -Filter 'fix_*.png' -ErrorAction SilentlyContinue | ForEach-Object {
  Copy-Item $_.FullName (Join-Path $dest $_.Name) -Force
  Write-Output ("copied " + $_.Name)
}

# Echo the console log so assertions / scale values are visible.
Write-Output "----- godot log -----"
Get-Content $out
