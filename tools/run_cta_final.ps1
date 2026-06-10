# Final CTA verification with the FeedbackBus popup-overlap regression + real screenshots.
$godot   = "C:\Users\JS Park\Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64.exe"
$proj    = "C:\Projects\kfood-game\godot-project"
$userdir = "C:\Users\JS Park\AppData\Roaming\Godot\app_userdata\K-Food Master"
$dest    = "C:\Projects\kfood-game\assets-raw\_screenshots\realism_fix"
$out     = "C:\Projects\kfood-game\tools\cta_final_out.txt"
New-Item -ItemType Directory -Force -Path $dest | Out-Null
& $godot --path $proj --rendering-driver opengl3 --resolution 540x960 --quit-after 1500 "res://scenes/result_cta_playtest.tscn" *>&1 | Out-File -FilePath $out -Encoding utf8
"EXIT=$LASTEXITCODE" | Out-File -FilePath $out -Append -Encoding utf8
Get-ChildItem $userdir -Filter 'cta_playtest_*.png' -ErrorAction SilentlyContinue | ForEach-Object {
  Copy-Item $_.FullName (Join-Path $dest $_.Name) -Force
  Write-Output ("copied " + $_.Name)
}
