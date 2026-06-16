# Render Build=Roll setup + visible bamboo mat + continuity F5 verification (real opengl3
# viewport, full 1080x1920) then copy the PNGs out of user:// into
# assets-raw/_screenshots/gimbap_buildroll/.
$godot   = "C:\Users\JS Park\Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64.exe"
$proj    = "C:\Projects\kfood-game\godot-project"
$userdir = "C:\Users\JS Park\AppData\Roaming\Godot\app_userdata\K-Food Master\gimbap_buildroll"
$dest    = "C:\Projects\kfood-game\assets-raw\_screenshots\gimbap_buildroll"
$out     = "C:\Projects\kfood-game\tools\gimbap_buildroll_out.txt"

New-Item -ItemType Directory -Force -Path $dest | Out-Null
& $godot --path $proj --rendering-driver opengl3 --resolution 540x960 --quit-after 9000 "res://scenes/shot_gimbap_buildroll.tscn" *>&1 | Out-File -FilePath $out -Encoding utf8
"EXIT=$LASTEXITCODE" | Out-File -FilePath $out -Append -Encoding utf8

# Copy generated PNGs from user://gimbap_buildroll to the screenshot dir.
Get-ChildItem $userdir -Filter '*.png' -ErrorAction SilentlyContinue | ForEach-Object {
  Copy-Item $_.FullName (Join-Path $dest $_.Name) -Force
  Write-Output ("copied " + $_.Name)
}
