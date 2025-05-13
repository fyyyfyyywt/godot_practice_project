extends Control

@export var fire_rate_timer: ProgressBar
@export var fire_rate_indicator: TextureRect  # TextureRect or Label


func update_fire_rate_timer(time_left: float, max_time: float) -> void:
	if time_left > 0:
		fire_rate_timer.visible = true
		fire_rate_timer.max_value = max_time
		fire_rate_timer.value = time_left
	else:
		fire_rate_timer.visible = false

func set_power_up_active(power_up_type: String, is_active: bool) -> void:
	match power_up_type:
		"fire_rate":
			fire_rate_indicator.visible = is_active
