extends Node

const SAVE_PATH := "user://save_data.cfg"

var _config: ConfigFile = ConfigFile.new()
var _loaded := false

func _ensure_loaded():
	if _loaded:
		return
	var err = _config.load(SAVE_PATH)
	if err != OK:
		print("⚠️ 没有发现存档文件，创建新配置")
	_loaded = true

func save_temp_score(score: int) -> void:
	_ensure_loaded()
	_config.set_value("progress", "temp_score", score)
	_config.save(SAVE_PATH)

func try_save_high_score():
	_ensure_loaded()
	var temp : int = _config.get_value("progress", "temp_score", 0)
	var best : int = _config.get_value("progress", "high_score", 0)
	if temp > best:
		print("🎉 更新最高分为:", temp)
		_config.set_value("progress", "high_score", temp)
	_config.set_value("progress", "temp_score", 0)
	_config.save(SAVE_PATH)

func get_high_score() -> int:
	_ensure_loaded()
	return _config.get_value("progress", "high_score", 0)

func has_seen_intro() -> bool:
	_ensure_loaded()
	return _config.get_value("progress", "intro_seen", false)

func mark_intro_seen():
	_ensure_loaded()
	_config.set_value("progress", "intro_seen", true)
	_config.save(SAVE_PATH)
