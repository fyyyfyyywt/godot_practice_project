extends Control

@export var fire_rate: HBoxContainer
@export var speed_up: HBoxContainer
@export var fire_rate_timer: ProgressBar
@export var speed_rate_timer: ProgressBar


func update_fire_rate_timer(time_left: float, max_time: float) -> void:
	if time_left > 0:
		fire_rate_timer.max_value = max_time
		fire_rate_timer.value = time_left

func update_speed_timer(time_left: float, max_time: float) -> void:
	if time_left > 0:
		speed_rate_timer.max_value = max_time
		speed_rate_timer.value = time_left
		
func set_power_up_active(power_up_type: String, is_active: bool) -> void:
	match power_up_type:
		"fire_rate":
			fire_rate.visible = is_active
		"speed":
			speed_up.visible = is_active
			
