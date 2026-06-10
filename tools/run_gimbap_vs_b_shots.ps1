# Render Gimbap Vertical Slice Pass B verification shots (real opengl3 viewport) then copy
# the PNGs out of user:// into assets-raw/_screenshots/gimbap_vs_b/.
$godot   = "C:\Users\JS Park\Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64.exe"
$proj    = "C:\Projects\kfood-game\godot-project"
$userdir = "C:\Users\JS Park\AppData\Roaming\Godot\app_userdata\K-Food Master"
$dest    = "C:\Projects\kfood-game\assets-raw\_screenshots\gimbap_vs_b"
$out     = "C:\Projects\kfood-game\tools\gimbap_vs_b_out.txt"

New-Item -ItemType Directory -Force -Path $dest | Out-Null
& $godot --path $proj --rendering-driver opengl3 --resolution 540x960 --quit-after 6500 "res://scenes/shot_gimbap_vs_b.tscn" *>&1 | Out-File -FilePath $out -Encoding utf8
"EXIT=$LASTEXITCODE" | Out-File -FilePath $out -Append -Encoding utf8

# Copy generated gvsb_*.png from user:// to the gimbap_vs_b screenshot dir (renamed).
Get-ChildItem $userdir -Filter 'gvsb_*.png' -ErrorAction SilentlyContinue | ForEach-Object {
  $newName = $_.Name -replace '^gvsb_', ''
  Copy-Item $_.FullName (Join-Path $dest $newName) -Force
  Write-Output ("copied " + $newName)
}
