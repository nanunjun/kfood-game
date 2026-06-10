# Import roll-stage standalone assets into the Godot project.
#   roll 7 assets  -> godot-project/art/sprites/roll/{id}.png
#   content food   -> godot-project/art/sprites/food_content/{id}.png
# These are already transparent 1024x1024 cutouts (verified). Pure copy, no merge/bake.
$src      = "C:\Projects\kfood-game\assets-raw\roll_assets_m2"
$rollDst  = "C:\Projects\kfood-game\godot-project\art\sprites\roll"
$foodDst  = "C:\Projects\kfood-game\godot-project\art\sprites\food_content"
New-Item -ItemType Directory -Force -Path $rollDst | Out-Null
New-Item -ItemType Directory -Force -Path $foodDst | Out-Null

$rollIds = @(
  "seaweed_sheet","rice_layer_flat",
  "gimbap_filling_strip_carrot","gimbap_filling_strip_egg","gimbap_filling_strip_green",
  "gimbap_roll_halfway","gimbap_roll_finished_content_only"
)
foreach ($id in $rollIds) {
  $s = Join-Path $src "$id.png"
  if (Test-Path $s) { Copy-Item $s (Join-Path $rollDst "$id.png") -Force; Write-Output "roll  <- $id.png" }
  else { Write-Output "MISSING roll $id.png" }
}
# content-only food (bibimbap) -> food_content/
$cs = Join-Path $src "bibimbap_content_only.png"
if (Test-Path $cs) { Copy-Item $cs (Join-Path $foodDst "bibimbap_content_only.png") -Force; Write-Output "food_content <- bibimbap_content_only.png" }
else { Write-Output "MISSING bibimbap_content_only.png" }
Write-Output "DONE"
