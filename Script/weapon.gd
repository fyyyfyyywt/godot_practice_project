extends Node2D

@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.3  # 射速（秒/发）

var cooldown := 0.0

func _process(delta):
	if cooldown > 0:
		cooldown -= delta
		

func shoot(direction: Vector2):
	if cooldown > 0:
		return
	cooldown = fire_rate

	var bullet = bullet_scene.instantiate()
	bullet.global_position = $MuzzlePosition.global_position
	bullet.direction = direction.normalized()
	get_tree().current_scene.add_child(bullet)
