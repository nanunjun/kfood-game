# Render the P0 world-integration before/after shots (menu / result / cooking) in one
# real opengl3 run, then copy the PNGs out of user:// into
# assets-raw/_screenshots/world_integration/.
# Usage: pass the tag ("before" / "after") as $args[0].
param(
  [string]$Tag = "after"
)
$godot   = "C:\Users\JS Park\Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64.exe"
$proj    = "C:\Projects\kfood-game\godot-project"
$userdir = "C:\Users\JS Park\AppData\Roaming\Godot\app_userdata\K-Food Master\world_integration"
$dest    = "C:\Projects\kfood-game\assets-raw\_screenshots\world_integration"
$out     = "C:\Projects\kfood-game\tools\world_integration_out.txt"

New-Item -ItemType Directory -Force -Path $dest | Out-Null
$env:KFOOD_WI_TAG = $Tag
& $godot --path $proj --rendering-driver opengl3 --resolution 1080x1920 --quit-after 3000 "res://scenes/shot_world_integration.tscn" *>&1 | Out-File -FilePath $out -Encoding utf8
"EXIT=$LASTEXITCODE" | Out-File -FilePath $out -Append -Encoding utf8

foreach ($name in @("menu_$Tag.png", "result_$Tag.png", "cooking_$Tag.png")) {
  $src = Join-Path $userdir $name
  if (Test-Path $src) {
    Copy-Item $src (Join-Path $dest $name) -Force
    Write-Output ("copied " + $name)
  } else {
    Write-Output ("MISSING " + $src)
  }
}
