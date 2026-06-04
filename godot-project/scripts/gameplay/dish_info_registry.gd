## DishInfoRegistry — food_id → 외국인용 요리 소개(영어 tagline + 설명).
##
## 외국 플레이어가 한식을 모를 수 있으므로, 라운드 시작 전 소개 화면(StageIntro)에서
## "이게 어떤 음식인지" 큰 이미지와 함께 보여주기 위한 텍스트 데이터.
## 레지스트리 패턴(ArtRegistry/ShoppingRegistry와 동일) — 코드 상수로 관리.
##
## tagline = 한 줄 카테고리/한마디, description = 1~2문장 친절한 설명.
class_name DishInfoRegistry
extends RefCounted

const INFO := {
	"t1_002": {
		"tagline": "Noodle soup · Korea's comfort food",
		"description": "Springy ramyeon noodles in a bold, spicy-savory broth, finished with a soft egg and green onion. Korea's most-loved quick comfort meal.",
	},
	"t1_003": {
		"tagline": "Street snack · sweet & spicy",
		"description": "Chewy cylindrical rice cakes simmered in a glossy sweet-and-spicy gochujang sauce with fish cake. Korea's most famous street food.",
	},
	"t1_004": {
		"tagline": "Rice roll · picnic favorite",
		"description": "Rice and colorful fillings rolled in seaweed and sliced into bite-size rounds. A portable Korean classic — not sushi!",
	},
	"t1_005": {
		"tagline": "Fried rice · home classic",
		"description": "Rice stir-fried with tangy kimchi and topped with a sunny-side-up egg. A fast, savory dish made from fridge staples.",
	},
	"t1_006": {
		"tagline": "Savory pancake · seafood",
		"description": "A crispy pan-fried pancake packed with green onions and seafood like shrimp and squid. A favorite on rainy days.",
	},
	"t1_007": {
		"tagline": "Street snack · deep-fried",
		"description": "A sausage on a stick in a crunchy deep-fried coating, often with stretchy cheese and a dusting of sugar. A viral K-street treat.",
	},
	"t1_008": {
		"tagline": "Noodle soup · light & gentle",
		"description": "Thin wheat noodles in a clear, light anchovy broth with delicate toppings. A mild 'celebration' noodle dish.",
	},
	"t2_008": {
		"tagline": "Mixed rice bowl · signature",
		"description": "A bowl of rice topped with assorted seasoned vegetables, beef and a fried egg. Mix everything together before eating.",
	},
	"t2_010": {
		"tagline": "Glass noodles · holiday dish",
		"description": "Glassy sweet-potato noodles stir-fried with colorful vegetables and beef. A sweet-savory dish served at celebrations.",
	},
	"t2_012": {
		"tagline": "Korean BBQ · grilled ribs",
		"description": "Marinated beef short ribs grilled until caramelized and smoky. The star of a Korean barbecue table.",
	},
	"t2_013": {
		"tagline": "Stew · silky soft tofu",
		"description": "A bubbling spicy stew of silky uncurdled soft tofu with a cracked egg, served sizzling in a stone pot.",
	},
	"t2_014": {
		"tagline": "Korean BBQ · marinated beef",
		"description": "Thin slices of beef marinated in a sweet soy sauce, then stir-fried. Famous worldwide as Korean 'fire meat'.",
	},
}


## food_id의 소개 정보 반환 (없으면 빈 tagline/description).
static func get_info(food_id: StringName) -> Dictionary:
	return INFO.get(String(food_id), {"tagline": "", "description": ""})


static func tagline(food_id: StringName) -> String:
	return String(get_info(food_id).get("tagline", ""))


static func description(food_id: StringName) -> String:
	return String(get_info(food_id).get("description", ""))
