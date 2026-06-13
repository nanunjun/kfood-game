# Render Gimbap Step 3 Build + Step 5 Slice F5 verification shots (real opengl3 viewport) then copy
# the PNGs out of user:// into assets-raw/_screenshots/gimbap_build_slice/.
$godot   = "C:\Users\JS Park\Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64.exe"
$proj    = "C:\Projects\kfood-game\godot-project"
$userdir = "C:\Users\JS Park\AppData\Roaming\Godot\app_userdata\K-Food Master\gimbap_build_slice"
$dest    = "C:\Projects\kfood-game\assets-raw\_screenshots\gimbap_build_slice"
$out     = "C:\Projects\kfood-game\tools\gimbap_build_slice_out.txt"

New-Item -ItemType Directory -Force -Path $dest | Out-Null
& $godot --path $proj --rendering-driver opengl3 --resolution 540x960 --quit-after 16000 "res://scenes/shot_gimbap_build_slice.tscn" *>&1 | Out-File -FilePath $out -Encoding utf8
"EXIT=$LASTEXITCODE" | Out-File -FilePath $out -Append -Encoding utf8

# Copy generated *.png from user://gimbap_build_slice to the screenshot dir.
Get-ChildItem $userdir -Filter '*.png' -ErrorAction SilentlyContinue | ForEach-Object {
  Copy-Item $_.FullName (Join-Path $dest $_.Name) -Force
  Write-Output ("copied " + $_.Name)
}
