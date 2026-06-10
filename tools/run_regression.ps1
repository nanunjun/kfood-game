# Run the GDScript regression smoke suite headless. Captures each scene's PASS/FAIL summary.
$godot = "C:\Users\JS Park\Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64.exe"
$proj  = "C:\Projects\kfood-game\godot-project"
$out   = "C:\Projects\kfood-game\tools\regression_out.txt"
$scenes = @(
  "res://scenes/cooking_modules_smoke.tscn",
  "res://scenes/cooking_runner_integration_smoke.tscn",
  "res://scenes/action_first_w1_smoke.tscn",
  "res://scenes/action_first_w2_smoke.tscn",
  "res://scenes/result_v2_smoke.tscn",
  "res://scenes/guest_v2_smoke.tscn",
  "res://scenes/save_migration_test.tscn",
  "res://scenes/protagonist_smoke.tscn",
  "res://scenes/gimbap_vs_smoke.tscn"
)
"" | Out-File -FilePath $out -Encoding utf8
foreach ($s in $scenes) {
  "==================== $s ====================" | Out-File -FilePath $out -Append -Encoding utf8
  & $godot --headless --path $proj --quit-after 1200 $s *>&1 | Out-File -FilePath $out -Append -Encoding utf8
  "[scene-exit=$LASTEXITCODE]" | Out-File -FilePath $out -Append -Encoding utf8
}
"ALLDONE" | Out-File -FilePath $out -Append -Encoding utf8
