# Render the TWO-FINGER gimbap roll redesign verification shots (real opengl3 viewport) then
# copy the PNGs out of user:// into assets-raw/_screenshots/roll_two_finger/.
$godot   = "C:\Users\JS Park\Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64.exe"
$proj    = "C:\Projects\kfood-game\godot-project"
$userdir = "C:\Users\JS Park\AppData\Roaming\Godot\app_userdata\K-Food Master"
$dest    = "C:\Projects\kfood-game\assets-raw\_screenshots\roll_two_finger"
$out     = "C:\Projects\kfood-game\tools\roll_two_finger_out.txt"

New-Item -ItemType Directory -Force -Path $dest | Out-Null
& $godot --path $proj --rendering-driver opengl3 --resolution 540x960 --quit-after 2400 "res://scenes/shot_roll_two_finger.tscn" *>&1 | Out-File -FilePath $out -Encoding utf8
"EXIT=$LASTEXITCODE" | Out-File -FilePath $out -Append -Encoding utf8

# Copy generated roll2f_*.png from user:// to the two-finger screenshot dir (renamed).
Get-ChildItem $userdir -Filter 'roll2f_*.png' -ErrorAction SilentlyContinue | ForEach-Object {
  $newName = $_.Name -replace '^roll2f_', ''
  Copy-Item $_.FullName (Join-Path $dest $newName) -Force
  Write-Output ("copied " + $newName)
}
