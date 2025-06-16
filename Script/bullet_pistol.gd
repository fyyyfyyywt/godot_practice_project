extends Area2D

@export var bullet_speed: float = 300.0  # 子弹速度，适合快节奏
@export var direction: Vector2 = Vector2.ZERO
var screen_rect: Rect2

func _ready():
	screen_rect = get_viewport().get_visible_rect()
	
func _physics_process(delta: float) -> void:
	global_position += direction * bullet_speed * delta
	
	if not screen_rect.has_point(global_position):
		queue_free()
