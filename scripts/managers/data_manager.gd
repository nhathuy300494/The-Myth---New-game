extends Node
class_name DataManagerNode

const ENEMY_FILE_PATH: String = "res://data/json/EnemyStat.json"
const PASSIVE_FILE_PATH: String = "res://data/json/Passive.json"
const SKILL_FILE_PATH: String = "res://data/json/Skill.json"
const QUEST_FILE_PATH: String = "res://data/json/Quest.json"

var _enemy_data: Dictionary[String, Dictionary] = {}
var _passive_data: Dictionary[String, Dictionary] = {}
var _skill_data: Dictionary[String, Dictionary] = {}
var _quest_data: Dictionary[String, Dictionary] = {}
var _validation_reason: String = ""

# Load all configured data sources when DataManager enters scene tree.
func _ready() -> void:
	load_all_data()

# Load all gameplay data JSON files through a centralized entry point.
func load_all_data() -> void:
	_enemy_data = _load_dictionary_by_id(ENEMY_FILE_PATH, "enemies", _validate_enemy_entry)
	_passive_data = _load_dictionary_by_id(PASSIVE_FILE_PATH, "passives", _validate_passive_entry)
	_skill_data = _load_dictionary_by_id(SKILL_FILE_PATH, "skills", _validate_skill_entry)
	_quest_data = _load_dictionary_by_id(QUEST_FILE_PATH, "quests", _validate_quest_entry)

	print("[DataManager] Load completed. Enemies=%d, Passives=%d, Skills=%d, Quests=%d" % [
		_enemy_data.size(),
		_passive_data.size(),
		_skill_data.size(),
		_quest_data.size()
	])

# Get a single enemy definition by id.
func get_enemy(enemy_id: String) -> Dictionary:
	if not _enemy_data.has(enemy_id):
		push_warning("[DataManager] Enemy id not found: %s" % enemy_id)
		return {}
	return _enemy_data[enemy_id]

# Get a single passive definition by id.
func get_passive(passive_id: String) -> Dictionary:
	if not _passive_data.has(passive_id):
		push_warning("[DataManager] Passive id not found: %s" % passive_id)
		return {}
	return _passive_data[passive_id]

# Get a single skill definition by id.
func get_skill(skill_id: String) -> Dictionary:
	if not _skill_data.has(skill_id):
		push_warning("[DataManager] Skill id not found: %s" % skill_id)
		return {}
	return _skill_data[skill_id]

# Get a single quest definition by id.
func get_quest(quest_id: String) -> Dictionary:
	if not _quest_data.has(quest_id):
		push_warning("[DataManager] Quest id not found: %s" % quest_id)
		return {}
	return _quest_data[quest_id]

# Get all loaded enemy definitions.
func get_all_enemies() -> Dictionary[String, Dictionary]:
	return _enemy_data.duplicate(true)

# Get all loaded passive definitions.
func get_all_passives() -> Dictionary[String, Dictionary]:
	return _passive_data.duplicate(true)

# Get all loaded skill definitions.
func get_all_skills() -> Dictionary[String, Dictionary]:
	return _skill_data.duplicate(true)

# Get all loaded quest definitions.
func get_all_quests() -> Dictionary[String, Dictionary]:
	return _quest_data.duplicate(true)

# Load JSON file, validate entries, and map data into Dictionary keyed by id.
func _load_dictionary_by_id(file_path: String, list_key: String, validator: Callable) -> Dictionary[String, Dictionary]:
	var mapped_data: Dictionary[String, Dictionary] = {}
	var parsed_data: Variant = _read_json_file(file_path)

	if typeof(parsed_data) != TYPE_DICTIONARY:
		push_warning("[DataManager] Root JSON is not Dictionary for: %s" % file_path)
		return mapped_data

	var root: Dictionary = parsed_data as Dictionary
	if not root.has(list_key):
		push_warning("[DataManager] Missing key '%s' in: %s" % [list_key, file_path])
		return mapped_data

	if typeof(root[list_key]) != TYPE_ARRAY:
		push_warning("[DataManager] Key '%s' is not Array in: %s" % [list_key, file_path])
		return mapped_data

	var rows: Array = root[list_key] as Array
	for row_variant: Variant in rows:
		if typeof(row_variant) != TYPE_DICTIONARY:
			push_warning("[DataManager] Skipped non-Dictionary row in: %s" % file_path)
			continue

		var row: Dictionary = row_variant as Dictionary
		_validation_reason = ""
		if not validator.call(row):
			push_warning("[DataManager] Validation failed for row in: %s" % file_path)
			push_warning("[DataManager] Invalid row in %s: %s" % [file_path, str(row)])
			push_warning("[DataManager] Reason: %s" % _validation_reason)
			continue

		var row_id: String = String(row["id"])
		if mapped_data.has(row_id):
			push_warning("[DataManager] Validation failed for row in: %s" % file_path)
			push_warning("[DataManager] Invalid row in %s: %s" % [file_path, str(row)])
			push_warning("[DataManager] Reason: duplicate id '%s'" % row_id)
			continue
		mapped_data[row_id] = row

	return mapped_data

# Read and parse a JSON file, returning Variant root on success.
func _read_json_file(file_path: String) -> Variant:
	if not FileAccess.file_exists(file_path):
		push_warning("[DataManager] File not found: %s" % file_path)
		return {}

	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_warning("[DataManager] Cannot open file: %s" % file_path)
		return {}

	var raw_text: String = file.get_as_text()
	var json: JSON = JSON.new()
	var parse_code: int = json.parse(raw_text)
	if parse_code != OK:
		push_warning("[DataManager] JSON parse error in %s at line %d" % [file_path, json.get_error_line()])
		return {}

	return json.data

# Validate enemy JSON row schema and required keys.
func _validate_enemy_entry(entry: Dictionary) -> bool:
	var required_keys: Array[String] = ["id", "name", "rank", "base_stats", "skills", "passive_effects", "ai_pattern", "reward"]
	if not _has_required_keys(entry, required_keys):
		_validation_reason = "missing required key(s) for enemy entry"
		return false

	if typeof(entry["id"]) != TYPE_STRING:
		_validation_reason = "id must be string"
		return false
	if typeof(entry["name"]) != TYPE_STRING:
		_validation_reason = "name must be string"
		return false
	if typeof(entry["rank"]) != TYPE_INT:
		_validation_reason = "rank must be int"
		return false

	if not _validate_stat_block(entry["base_stats"]):
		_validation_reason = "base_stats must include STR/INT/DEX/VIT"
		return false

	if typeof(entry["skills"]) != TYPE_ARRAY:
		_validation_reason = "skills must be array"
		return false
	if typeof(entry["passive_effects"]) != TYPE_ARRAY:
		_validation_reason = "passive_effects must be array"
		return false
	if typeof(entry["ai_pattern"]) != TYPE_ARRAY:
		_validation_reason = "ai_pattern must be array"
		return false

	if typeof(entry["reward"]) != TYPE_DICTIONARY:
		_validation_reason = "reward must be dictionary"
		return false
	var reward: Dictionary = entry["reward"] as Dictionary
	if not _has_required_keys(reward, ["gold", "exp"]):
		_validation_reason = "reward must contain gold and exp"
		return false
	if typeof(reward["gold"]) != TYPE_INT:
		_validation_reason = "reward.gold must be int"
		return false
	if typeof(reward["exp"]) != TYPE_INT:
		_validation_reason = "reward.exp must be int"
		return false

	return true

# Validate passive JSON row schema and required keys.
func _validate_passive_entry(entry: Dictionary) -> bool:
	var required_keys: Array[String] = ["id", "name", "rarity", "max_level", "stat_bonus", "active_effect", "description"]
	if not _has_required_keys(entry, required_keys):
		_validation_reason = "missing required key(s) for passive entry"
		return false

	if typeof(entry["id"]) != TYPE_STRING:
		_validation_reason = "id must be string"
		return false
	if typeof(entry["name"]) != TYPE_STRING:
		_validation_reason = "name must be string"
		return false
	if typeof(entry["rarity"]) != TYPE_STRING:
		_validation_reason = "rarity must be string"
		return false
	if typeof(entry["max_level"]) != TYPE_INT:
		_validation_reason = "max_level must be int"
		return false

	if not _validate_stat_block(entry["stat_bonus"]):
		_validation_reason = "stat_bonus must include STR/INT/DEX/VIT"
		return false

	return true

# Validate skill JSON row schema and required keys.
func _validate_skill_entry(entry: Dictionary) -> bool:
	var required_keys: Array[String] = ["id", "name", "type", "resource_cost", "status_effect", "effect_value", "description"]
	if not _has_required_keys(entry, required_keys):
		_validation_reason = "missing required key(s) for skill entry"
		return false

	if typeof(entry["id"]) != TYPE_STRING:
		_validation_reason = "id must be string"
		return false
	if typeof(entry["name"]) != TYPE_STRING:
		_validation_reason = "name must be string"
		return false
	if typeof(entry["type"]) != TYPE_STRING:
		_validation_reason = "type must be string"
		return false
	if typeof(entry["effect_value"]) != TYPE_INT:
		_validation_reason = "effect_value must be int"
		return false

	if typeof(entry["resource_cost"]) != TYPE_DICTIONARY:
		_validation_reason = "resource_cost must be dictionary"
		return false
	var resource_cost: Dictionary = entry["resource_cost"] as Dictionary
	if not _has_required_keys(resource_cost, ["mp", "ki"]):
		_validation_reason = "resource_cost must contain mp and ki"
		return false
	if typeof(resource_cost["mp"]) != TYPE_INT:
		_validation_reason = "resource_cost.mp must be int"
		return false
	if typeof(resource_cost["ki"]) != TYPE_INT:
		_validation_reason = "resource_cost.ki must be int"
		return false

	return true

# Validate quest JSON row schema and required keys.
func _validate_quest_entry(entry: Dictionary) -> bool:
	var required_keys: Array[String] = ["id", "name", "type", "objectives", "time_limit", "rewards", "branching_flags"]
	if not _has_required_keys(entry, required_keys):
		_validation_reason = "missing required key(s) for quest entry"
		return false

	if typeof(entry["id"]) != TYPE_STRING:
		_validation_reason = "id must be string"
		return false
	if typeof(entry["name"]) != TYPE_STRING:
		_validation_reason = "name must be string"
		return false
	if typeof(entry["type"]) != TYPE_STRING:
		_validation_reason = "type must be string"
		return false
	if typeof(entry["time_limit"]) != TYPE_INT:
		_validation_reason = "time_limit must be int"
		return false

	if typeof(entry["objectives"]) != TYPE_ARRAY:
		_validation_reason = "objectives must be array"
		return false
	if typeof(entry["branching_flags"]) != TYPE_ARRAY:
		_validation_reason = "branching_flags must be array"
		return false
	if typeof(entry["rewards"]) != TYPE_DICTIONARY:
		_validation_reason = "rewards must be dictionary"
		return false

	return true

# Validate stat block structure using core stat names.
func _validate_stat_block(stat_block_variant: Variant) -> bool:
	if typeof(stat_block_variant) != TYPE_DICTIONARY:
		return false

	var stat_block: Dictionary = stat_block_variant as Dictionary
	var required_stats: Array[String] = ["STR", "INT", "DEX", "VIT"]
	return _has_required_keys(stat_block, required_stats)

# Check whether a dictionary contains all required keys.
func _has_required_keys(dict_value: Dictionary, keys: Array[String]) -> bool:
	for key_name: String in keys:
		if not dict_value.has(key_name):
			return false
	return true
