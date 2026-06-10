# Render the Gimbap Roll bottom-to-top first-person reframe verification shots (real opengl3
# viewport) then copy the PNGs out of user:// into assets-raw/_screenshots/roll_bottom_top/.
$godot   = "C:\Users\JS Park\Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64.exe"
$proj    = "C:\Projects\kfood-game\godot-project"
$userdir = "C:\Users\JS Park\AppData\Roaming\Godot\app_userdata\K-Food Master"
$dest    = "C:\Projects\kfood-game\assets-raw\_screenshots\roll_bottom_top"
$out     = "C:\Projects\kfood-game\tools\roll_bottom_top_out.txt"

New-Item -ItemType Directory -Force -Path $dest | Out-Null
& $godot --path $proj --rendering-driver opengl3 --resolution 540x960 --quit-after 1800 "res://scenes/shot_roll_layout_fix.tscn" *>&1 | Out-File -FilePath $out -Encoding utf8
"EXIT=$LASTEXITCODE" | Out-File -FilePath $out -Append -Encoding utf8

# Copy generated roll_layout_*.png from user:// to the bottom-top screenshot dir (renamed).
Get-ChildItem $userdir -Filter 'roll_layout_*.png' -ErrorAction SilentlyContinue | ForEach-Object {
  $newName = $_.Name -replace '^roll_layout_', ''
  Copy-Item $_.FullName (Join-Path $dest $newName) -Force
  Write-Output ("copied " + $newName)
}
