# Render Roll 이중 이미지 제거 + 재료 얇게 F5 verification shots (real opengl3 viewport) then
# copy the PNGs out of user:// into assets-raw/_screenshots/gimbap_rollfix/.
$godot   = "C:\Users\JS Park\Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64.exe"
$proj    = "C:\Projects\kfood-game\godot-project"
$userdir = "C:\Users\JS Park\AppData\Roaming\Godot\app_userdata\K-Food Master"
$dest    = "C:\Projects\kfood-game\assets-raw\_screenshots\gimbap_rollfix"
$out     = "C:\Projects\kfood-game\tools\gimbap_rollfix_out.txt"

New-Item -ItemType Directory -Force -Path $dest | Out-Null
& $godot --path $proj --rendering-driver opengl3 --resolution 540x960 --quit-after 3400 "res://scenes/shot_gimbap_rollfix.tscn" *>&1 | Out-File -FilePath $out -Encoding utf8
"EXIT=$LASTEXITCODE" | Out-File -FilePath $out -Append -Encoding utf8

# Copy generated grollfix_*.png from user:// to the gimbap_rollfix screenshot dir (renamed).
Get-ChildItem $userdir -Filter 'grollfix_*.png' -ErrorAction SilentlyContinue | ForEach-Object {
  $newName = $_.Name -replace '^grollfix_', ''
  Copy-Item $_.FullName (Join-Path $dest $newName) -Force
  Write-Output ("copied " + $newName)
}
