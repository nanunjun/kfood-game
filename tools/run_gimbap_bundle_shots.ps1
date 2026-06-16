# Render Gimbap Build "두툼한 색색 다발" F5 verification shot at full 1080x1920 (real opengl3
# viewport, real drag input) then copy the PNG into assets-raw/_screenshots/gimbap_bundle/.
$godot   = "C:\Users\JS Park\Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64.exe"
$proj    = "C:\Projects\kfood-game\godot-project"
$userdir = "C:\Users\JS Park\AppData\Roaming\Godot\app_userdata\K-Food Master\gimbap_bundle"
$dest    = "C:\Projects\kfood-game\assets-raw\_screenshots\gimbap_bundle"
$out     = "C:\Projects\kfood-game\tools\gimbap_bundle_out.txt"

New-Item -ItemType Directory -Force -Path $dest | Out-Null
& $godot --path $proj --rendering-driver opengl3 --resolution 1080x1920 --quit-after 9000 "res://scenes/shot_gimbap_bundle.tscn" *>&1 | Out-File -FilePath $out -Encoding utf8
"EXIT=$LASTEXITCODE" | Out-File -FilePath $out -Append -Encoding utf8

Get-ChildItem $userdir -Filter '*.png' -ErrorAction SilentlyContinue | ForEach-Object {
  Copy-Item $_.FullName (Join-Path $dest $_.Name) -Force
  Write-Output ("copied " + $_.Name)
}
