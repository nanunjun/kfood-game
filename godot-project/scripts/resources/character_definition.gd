## CharacterDefinition — 주인공 / 친구 (어머니·아버지 등) 공통 Resource.
##
## MVP 캐릭터: 주인공 1명 + 어머니(mother_01) + 아버지(father_01).
## friends-system.md v0.3의 호불호 axis는 별도 FriendDefinition resource로 분리 가능 (post-launch).
## 본 sprint는 공통 schema만 lock — M2에서 어머니/아버지 정서 reaction 데이터 추가.
## 등록 위치: godot-project/resources/characters/{character_id}.tres
##
## 참조:
##   - docs/systems/friends-system.md (어머니·아버지 personality)
##   - docs/art-style-guide.md §3 (캐릭터 마스코트 스타일)
class_name CharacterDefinition
extends Resource

## 캐릭터 고유 ID (예: "player_01", "mother_01", "father_01").
@export var character_id: StringName = &""

## UI 표시명 (예: "엄마", "아빠"). 호칭은 사용자 customize 후보 (post-launch).
@export var display_name: String = ""

## 역할 — player / mother / father / friend (post-launch).
@export var role: StringName = &"player"

## 기본 sprite (Neutral 표정). 예: "res://art/sprites/mother_neutral.png".
@export_file("*.png", "*.svg", "*.webp") var sprite_path: String = ""

## ★1/★2/★3 reaction 이미지 anchor 경로 dictionary.
##   key: StringName (&"star_1", &"star_2", &"star_3", &"happy", &"subtle")
##   value: String (path)
## art-style-guide §3.5 표정 anchor 3종(Neutral/Happy/Subtle) 기준.
##   U-2 양친 0.6s 시차 unlock 컷씬 시 anchor reaction을 AnimationPlayer로 시퀀싱 (M2 sprint).
@export var reaction_anchor_paths: Dictionary = {}
