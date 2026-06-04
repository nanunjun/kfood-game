## ShoppingRegistry - food_id -> correct ingredients (auto-gen: tools/gen_shopping_from_csv.py).
## CORRECT(flat) / CORRECT_BY_STORE / POOL_BY_STORE. basic_pantry excluded.
class_name ShoppingRegistry
extends RefCounted

const CORRECT := {
	"t1_002": ["Green Onion", "Ramyeon Noodle", "Egg"],
	"t1_003": ["Green Onion", "Onion", "Fish Cake", "Tteok (Rice Cake)"],
	"t1_004": ["Spinach", "Ham", "Dried Seaweed", "Cooked Rice", "Egg", "Pickled Radish"],
	"t1_005": ["Green Onion", "Ham", "Cooked Rice", "Egg", "Kimchi"],
	"t1_006": ["Green Onion", "Chive Onion", "Onion", "Korean Chive", "Squid", "Shrimp", "Clam", "Pancake Mix", "Egg"],
	"t1_007": ["Sausage", "Pancake Mix", "Bread Crumb", "Mozzarella", "Ketchup"],
	"t1_008": ["Green Onion", "Young Korean Zucchini", "Dried Seaweed", "Anchovy", "Somen (White Wheat Noodle)", "Egg", "Minced Garlic"],
	"t2_008": ["Spinach", "Bean Sprout", "Carrot", "Beef", "Cooked Rice"],
	"t2_010": ["Onion", "Spinach", "Carrot", "Shiitake", "Beef", "Glass Noodle"],
	"t2_012": ["Garlic", "Korean Pear", "LA Galbi", "Premium Galbi", "Sesame Seed"],
	"t2_013": ["Green Onion", "Korean Zucchini", "Anchovy", "Egg", "Kimchi", "Soft Tofu", "Red Pepper Powder"],
	"t2_014": ["Green Onion", "Onion", "Korean Pear", "Carrot", "Shiitake", "Thin-Sliced Beef", "Minced Garlic"],
}

const CORRECT_BY_STORE := {
	"t1_002": {"grain": ["Ramyeon Noodle"], "produce": ["Green Onion"], "sundry": ["Egg"]},
	"t1_003": {"grain": ["Tteok (Rice Cake)"], "produce": ["Green Onion", "Onion"], "seafood": ["Fish Cake"]},
	"t1_004": {"grain": ["Cooked Rice"], "meat": ["Ham"], "produce": ["Spinach"], "seafood": ["Dried Seaweed"], "sundry": ["Egg", "Pickled Radish"]},
	"t1_005": {"grain": ["Cooked Rice"], "meat": ["Ham"], "produce": ["Green Onion"], "sundry": ["Egg", "Kimchi"]},
	"t1_006": {"grain": ["Pancake Mix"], "produce": ["Green Onion", "Chive Onion", "Onion", "Korean Chive"], "seafood": ["Squid", "Shrimp", "Clam"], "sundry": ["Egg"]},
	"t1_007": {"grain": ["Pancake Mix", "Bread Crumb"], "meat": ["Sausage"], "sundry": ["Mozzarella", "Ketchup"]},
	"t1_008": {"grain": ["Somen (White Wheat Noodle)"], "produce": ["Green Onion", "Young Korean Zucchini"], "seafood": ["Dried Seaweed", "Anchovy"], "sundry": ["Egg", "Minced Garlic"]},
	"t2_008": {"grain": ["Cooked Rice"], "meat": ["Beef"], "produce": ["Spinach", "Bean Sprout", "Carrot"]},
	"t2_010": {"grain": ["Glass Noodle"], "meat": ["Beef"], "produce": ["Onion", "Spinach", "Carrot", "Shiitake"]},
	"t2_012": {"meat": ["LA Galbi", "Premium Galbi"], "produce": ["Garlic", "Korean Pear"], "sundry": ["Sesame Seed"]},
	"t2_013": {"produce": ["Green Onion", "Korean Zucchini"], "seafood": ["Anchovy"], "sundry": ["Egg", "Kimchi", "Soft Tofu", "Red Pepper Powder"]},
	"t2_014": {"meat": ["Thin-Sliced Beef"], "produce": ["Green Onion", "Onion", "Korean Pear", "Carrot", "Shiitake"], "sundry": ["Minced Garlic"]},
}

const POOL_BY_STORE := {
	"grain": ["Ramyeon Noodle", "Cooked Rice", "Tteok (Rice Cake)", "Pancake Mix", "Bread Crumb", "Glass Noodle", "Somen (White Wheat Noodle)"],
	"meat": ["Sausage", "Ham", "Beef", "LA Galbi", "Premium Galbi", "Thin-Sliced Beef"],
	"produce": ["Green Onion", "Chive Onion", "Onion", "Korean Chive", "Garlic", "Korean Pear", "Spinach", "Bean Sprout", "Carrot", "Shiitake", "Korean Zucchini", "Young Korean Zucchini"],
	"seafood": ["Dried Seaweed", "Fish Cake", "Squid", "Shrimp", "Clam", "Anchovy"],
	"sundry": ["Egg", "Sesame Seed", "Pickled Radish", "Kimchi", "Mozzarella", "Ketchup", "Soft Tofu", "Red Pepper Powder", "Minced Garlic"],
}

static func correct(fid: StringName) -> Array:
	return CORRECT.get(String(fid), [])

static func correct_by_store(fid: StringName) -> Dictionary:
	return CORRECT_BY_STORE.get(String(fid), {})

static func pool_by_store(store: StringName) -> Array:
	return POOL_BY_STORE.get(String(store), [])
