## FoodDefinition — 한식 음식 1종의 데이터 정의 Resource.
##
## docs/foods-database.csv v2.1의 컬럼 1:1 매핑.
## MVP 12종 (Tier 1: 7개, Tier 2: 5개). 사용자/디자이너는 Godot Editor에서 .tres 파일로 인스턴스 생성.
## 등록 위치: godot-project/resources/foods/{food_id}.tres
##
## 참조:
##   - docs/foods-database.csv (source of truth)
##   - docs/balance-config.md v0.2 §3.2 (perfect_width_by_food)
##   - docs/systems/cooking-mechanics.md §4 (Stage 3 룰)
class_name FoodDefinition
extends Resource

## 음식 고유 ID (예: "t1_001", "t2_013"). foods-database.csv의 food_id와 1:1.
@export var food_id: StringName = &""

## 한국어 표기 (UI 출력 default).
@export var name_ko: String = ""

## 영어 표기 (글로벌 빌드 + 분석 이벤트용).
@export var name_en: String = ""

## Tier 등급 — MVP는 1 또는 2. (Tier 3~5는 post-launch.)
@export_range(1, 5, 1) var tier: int = 1

## 1인분 / 2인분 구분 (Tier 1 = 1, Tier 2 = 2).
@export_range(1, 6, 1) var servings: int = 1

## Stage 1에서 순회해야 하는 가게 수 (2~5).
@export_range(1, 5, 1) var store_count: int = 1

## 1차 조리 방법 (boil / grill / stirfry / panfry / deepfry / roll / mix). CookingMethodDefinition.method_id와 매치.
@export var primary_cooking_method: StringName = &""

## 2차 조리 방법 (없으면 빈 StringName). 잡채 예시: stirfry → toss.
@export var secondary_method: StringName = &""

## Stage 3 cook_time (초). foods-database.csv의 cook_time_sec.
@export_range(2.0, 30.0, 0.5) var cook_time_sec: float = 10.0

## Stage 3 PERFECT 판정 window (ms). foods-database.csv의 perfect_window_ms.
## balance-config §3.2 비율 환산: perfect_window_ms / (cook_time_sec × 1000 × 2)
@export_range(400.0, 2000.0, 50.0) var perfect_window_ms: float = 1000.0

## 난이도 점수 (1=쉬움 ~ 5=어려움). game-designer 주관 점수.
@export_range(1, 5, 1) var difficulty_score: int = 1

## 시각적 매력 점수 (1~5). MVP 스토어 스크린샷 후보 선정 기준.
@export_range(1, 5, 1) var visual_appeal_score: int = 3

## 글로벌 인지도 점수 (1~5). K-food 글로벌 트렌드 기준 (떡볶이/김치 = 5).
@export_range(1, 5, 1) var recognition_score: int = 3

## 광고 트리거 우선순위 — interstitial 빈도 가중 (low / med / high).
## low = 후방 배치, high = 라운드 종료 후 우선 노출.
@export_enum("low", "med", "high") var ad_trigger_priority: String = "med"

## 디자이너 메모 (CSV notes 컬럼).
@export_multiline var notes: String = ""
