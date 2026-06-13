# Render DEBUG_UNLOCK_ALL verification shots (real opengl3 viewport) and copy the
# PNGs out of user:// into assets-raw/_screenshots/unlock_all/.
#   1) menu_unlocked.png      — menu_select at Lv1, all 12 cards active (no lock stamp)
#   2) enter_bibimbap.png     — Bibimbap (Lv4) entered into the cooking runner
#   3) enter_sundubu.png      — Sundubu (Lv8, stock 0) entered into the cooking runner
$godot   = "C:\Users\JS Park\Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64.exe"
$proj    = "C:\Projects\kfood-game\godot-project"
$userdir = "C:\Users\JS Park\AppData\Roaming\Godot\app_userdata\K-Food Master"
$dest    = "C:\Projects\kfood-game\assets-raw\_screenshots\unlock_all"
$log     = "C:\Projects\kfood-game\tools\unlock_all_out.txt"

New-Item -ItemType Directory -Force -Path $dest | Out-Null
"" | Out-File -FilePath $log -Encoding utf8

# shot definitions: OutName | Mode (menu | <menu_id>)
$shots = @(
  @{ Out = "menu_unlocked.png";  Mode = "menu"   },
  @{ Out = "enter_bibimbap.png"; Mode = "t2_008" },  # Lv4
  @{ Out = "enter_sundubu.png";  Mode = "t2_013" }   # Lv8, stock 0
)

foreach ($s in $shots) {
  "==================== $($s.Out) (mode=$($s.Mode)) ====================" | Out-File -FilePath $log -Append -Encoding utf8
  $env:KFOOD_SHOT_OUT  = $s.Out
  $env:KFOOD_SHOT_MODE = $s.Mode
  & $godot --path $proj --rendering-driver opengl3 --resolution 1080x1920 --quit-after 2400 "res://scenes/shot_unlock_all.tscn" *>&1 |
    Out-File -FilePath $log -Append -Encoding utf8
  "[exit=$LASTEXITCODE]" | Out-File -FilePath $log -Append -Encoding utf8

  $src = Join-Path $userdir $s.Out
  if (Test-Path $src) {
    Copy-Item $src (Join-Path $dest $s.Out) -Force
    Write-Output ("copied " + $s.Out)
  } else {
    Write-Output ("MISSING " + $src)
  }
}
"ALLDONE" | Out-File -FilePath $log -Append -Encoding utf8
