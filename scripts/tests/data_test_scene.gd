extends Control

@onready var enemy_output_label: RichTextLabel = %EnemyOutputLabel
@onready var passive_output_label: RichTextLabel = %PassiveOutputLabel
@onready var skill_output_label: RichTextLabel = %SkillOutputLabel

# Render loaded data into debug labels and print console summary.
func _ready() -> void:
	if DataManager == null:
		push_warning("[DataTestScene] DataManager autoload is missing.")
		return

	_render_enemy_data()
	_render_passive_data()
	_render_skill_data()

	var enemy_count: int = DataManager.get_all_enemies().size()
	var passive_count: int = DataManager.get_all_passives().size()
	var skill_count: int = DataManager.get_all_skills().size()
	print("[DataTestScene] Loaded counts -> enemies=%d passives=%d skills=%d" % [enemy_count, passive_count, skill_count])
	print("[DataTestScene] Data mapping validation completed.")

# Render enemy definitions loaded by DataManager.
func _render_enemy_data() -> void:
	var lines: Array[String] = []
	for enemy_id: String in DataManager.get_all_enemies().keys():
		var enemy_data: Dictionary = DataManager.get_enemy(enemy_id)
		if enemy_data.is_empty():
			continue
		lines.append("%s | rank=%s | skills=%s" % [
			enemy_id,
			String(enemy_data["rank"]),
			str(enemy_data["skills"])
		])
		print("[DataTestScene][Enemy] %s" % lines[-1])
	enemy_output_label.text = "\n".join(lines)

# Render passive definitions loaded by DataManager.
func _render_passive_data() -> void:
	var lines: Array[String] = []
	for passive_id: String in DataManager.get_all_passives().keys():
		var passive_data: Dictionary = DataManager.get_passive(passive_id)
		if passive_data.is_empty():
			continue
		lines.append("%s | rarity=%s | max_level=%d" % [
			passive_id,
			String(passive_data["rarity"]),
			int(passive_data["max_level"])
		])
		print("[DataTestScene][Passive] %s" % lines[-1])
	passive_output_label.text = "\n".join(lines)

# Render skill definitions loaded by DataManager.
func _render_skill_data() -> void:
	var lines: Array[String] = []
	for skill_id: String in DataManager.get_all_skills().keys():
		var skill_data: Dictionary = DataManager.get_skill(skill_id)
		if skill_data.is_empty():
			continue
		lines.append("%s | type=%s | value=%d" % [
			skill_id,
			String(skill_data["type"]),
			int(skill_data["effect_value"])
		])
		print("[DataTestScene][Skill] %s" % lines[-1])
	skill_output_label.text = "\n".join(lines)
