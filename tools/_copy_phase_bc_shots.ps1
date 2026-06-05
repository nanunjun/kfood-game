$src = "C:\Users\JS Park\AppData\Roaming\Godot\app_userdata\K-Food Master"
$dst = "C:\Projects\kfood-game\assets-raw\_screenshots\phase_bc_avatar_swap"
New-Item -ItemType Directory -Path $dst -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $src "premium_v1_01_menu_select.png") -Destination (Join-Path $dst "01_menu_select.png") -Force
Copy-Item -LiteralPath (Join-Path $src "premium_v1_02_guest_select.png") -Destination (Join-Path $dst "02_guest_select.png") -Force
Copy-Item -LiteralPath (Join-Path $src "premium_v1_03_cooking.png") -Destination (Join-Path $dst "03_cooking.png") -Force
Copy-Item -LiteralPath (Join-Path $src "premium_v1_04_result_top.png") -Destination (Join-Path $dst "04_result_top.png") -Force
Copy-Item -LiteralPath (Join-Path $src "premium_v1_04_result_bottom.png") -Destination (Join-Path $dst "04_result_bottom.png") -Force
Get-ChildItem $dst | Select-Object Name, Length | Format-Table -AutoSize
