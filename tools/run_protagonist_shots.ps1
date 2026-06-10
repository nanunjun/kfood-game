# Render the Player-Chef Integration verification shots in one real opengl3 run, then
# copy the PNGs out of user:// into assets-raw/_screenshots/protagonist/.
$godot   = "C:\Users\JS Park\Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64.exe"
$proj    = "C:\Projects\kfood-game\godot-project"
$userdir = "C:\Users\JS Park\AppData\Roaming\Godot\app_userdata\K-Food Master\protagonist"
$dest    = "C:\Projects\kfood-game\assets-raw\_screenshots\protagonist"
$out     = "C:\Projects\kfood-game\tools\protagonist_shots_out.txt"

New-Item -ItemType Directory -Force -Path $dest | Out-Null
& $godot --path $proj --rendering-driver opengl3 --resolution 1080x1920 --quit-after 9000 "res://scenes/shot_protagonist.tscn" *>&1 | Out-File -FilePath $out -Encoding utf8
"EXIT=$LASTEXITCODE" | Out-File -FilePath $out -Append -Encoding utf8

foreach ($name in @("gender_select.png", "menu_host_f.png", "menu_host_m.png", "result_host_cheer.png", "cooking_request_think.png", "cooking_cook_host.png")) {
  $src = Join-Path $userdir $name
  if (Test-Path $src) {
    Copy-Item $src (Join-Path $dest $name) -Force
    Write-Output ("copied " + $name)
  } else {
    Write-Output ("MISSING " + $src)
  }
}
