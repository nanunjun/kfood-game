# Render the 외국인 캐릭터 배선 verification shots in one real opengl3 run, then copy the
# PNGs out of user:// into assets-raw/_screenshots/foreign_chars/.
$godot   = "C:\Users\JS Park\Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64.exe"
$proj    = "C:\Projects\kfood-game\godot-project"
$userdir = "C:\Users\JS Park\AppData\Roaming\Godot\app_userdata\K-Food Master\foreign_chars"
$dest    = "C:\Projects\kfood-game\assets-raw\_screenshots\foreign_chars"
$out     = "C:\Projects\kfood-game\tools\foreign_chars_shots_out.txt"

New-Item -ItemType Directory -Force -Path $dest | Out-Null
& $godot --path $proj --rendering-driver opengl3 --resolution 1080x1920 --quit-after 9000 "res://scenes/shot_foreign_chars.tscn" *>&1 | Out-File -FilePath $out -Encoding utf8
"EXIT=$LASTEXITCODE" | Out-File -FilePath $out -Append -Encoding utf8

foreach ($name in @("chef_select.png", "guest_select_foreign.png", "guest_select_foreign_scrolled.png", "result_sofia.png")) {
  $src = Join-Path $userdir $name
  if (Test-Path $src) {
    Copy-Item $src (Join-Path $dest $name) -Force
    Write-Output ("copied " + $name)
  } else {
    Write-Output ("MISSING " + $src)
  }
}
