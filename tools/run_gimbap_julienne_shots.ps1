# Render Gimbap Julienne RHYTHM SLICING verification shots (real opengl3 viewport) then copy
# the PNGs out of user:// into assets-raw/_screenshots/gimbap_julienne2/.
$godot   = "C:\Users\JS Park\Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64.exe"
$proj    = "C:\Projects\kfood-game\godot-project"
$userdir = "C:\Users\JS Park\AppData\Roaming\Godot\app_userdata\K-Food Master\gimbap_julienne2"
$dest    = "C:\Projects\kfood-game\assets-raw\_screenshots\gimbap_julienne2"
$out     = "C:\Projects\kfood-game\tools\gimbap_julienne_out.txt"

New-Item -ItemType Directory -Force -Path $dest | Out-Null
& $godot --path $proj --rendering-driver opengl3 --resolution 540x960 --quit-after 12000 "res://scenes/shot_gimbap_julienne.tscn" *>&1 | Out-File -FilePath $out -Encoding utf8
"EXIT=$LASTEXITCODE" | Out-File -FilePath $out -Append -Encoding utf8

# Copy generated *.png from user://gimbap_julienne2 to the screenshot dir.
Get-ChildItem $userdir -Filter '*.png' -ErrorAction SilentlyContinue | ForEach-Object {
  Copy-Item $_.FullName (Join-Path $dest $_.Name) -Force
  Write-Output ("copied " + $_.Name)
}
