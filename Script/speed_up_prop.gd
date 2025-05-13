extends Area2D
@export var despawn_time: float = 5.0  # Time before item disappears if not picked up
var is_touched : bool=false
var time_alive: float = 0.0

func _ready() -> void:
	add_to_group("SpeedUp_Props")  # Add to group for counting active items

func _physics_process(delta: float) -> void:
	if is_touched:
		queue_free()
	else:
		$AnimatedSprite2D.play("default")
		time_alive += delta
		if time_alive >= despawn_time:
			queue_free()

		
func _on_body_entered(body: Node2D) -> void:
	#确保撞到的是玩家
	if (body is CharacterBody2D) and (not is_touched):
		body.apply_speed_up()  # Call player's method to handle boost
		is_touched = true
