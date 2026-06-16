# Render Gimbap Build "tall portrait mat/seaweed + clean rice spread" F5 verification shot
# (real opengl3 viewport). Writes directly to assets-raw/_screenshots/gimbap_tall/.
$godot = "C:\Users\JS Park\Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64.exe"
$proj  = "C:\Projects\kfood-game\godot-project"
$dest  = "C:\Projects\kfood-game\assets-raw\_screenshots\gimbap_tall"
$out   = "C:\Projects\kfood-game\tools\gimbap_tall_out.txt"

New-Item -ItemType Directory -Force -Path $dest | Out-Null
& $godot --path $proj --rendering-driver opengl3 --resolution 540x960 --quit-after 2600 "res://scenes/shot_gimbap_tall.tscn" *>&1 | Out-File -FilePath $out -Encoding utf8
"EXIT=$LASTEXITCODE" | Out-File -FilePath $out -Append -Encoding utf8
Get-Content $out
