# Render the Recipe Board menu_select verification shot (real opengl3 viewport),
# then copy the PNG out of user:// into assets-raw/_screenshots/menu_recipe_board/.
# Usage: pass the output filename as $args[0] (e.g. menu_recipe_board_before.png).
param(
  [string]$OutName = "menu_recipe_board_after.png"
)
$godot   = "C:\Users\JS Park\Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64.exe"
$proj    = "C:\Projects\kfood-game\godot-project"
$userdir = "C:\Users\JS Park\AppData\Roaming\Godot\app_userdata\K-Food Master"
$dest    = "C:\Projects\kfood-game\assets-raw\_screenshots\menu_recipe_board"
$out     = "C:\Projects\kfood-game\tools\recipe_board_out.txt"

New-Item -ItemType Directory -Force -Path $dest | Out-Null
$env:KFOOD_SHOT_OUT = $OutName
& $godot --path $proj --rendering-driver opengl3 --resolution 1080x1920 --quit-after 1800 "res://scenes/shot_menu_recipe_board.tscn" *>&1 | Out-File -FilePath $out -Encoding utf8
"EXIT=$LASTEXITCODE" | Out-File -FilePath $out -Append -Encoding utf8

$src = Join-Path $userdir $OutName
if (Test-Path $src) {
  Copy-Item $src (Join-Path $dest $OutName) -Force
  Write-Output ("copied " + $OutName)
} else {
  Write-Output ("MISSING " + $src)
}
