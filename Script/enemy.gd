extends Area2D

signal slime_triggered_game_over  # Signal for boundary or player collision

@export var slime_speed : float=-100
@export var animator : AnimatedSprite2D

var is_dead : bool=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not is_dead:
		position += Vector2(slime_speed, 0)*delta
		if position.x < -255:
			emit_signal("slime_triggered_game_over")
			get_tree().current_scene.is_game_over = true
	else:
		animator.play("die")
		await get_tree().create_timer(0.5).timeout
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	#确保史莱姆撞到的是玩家
	if (body is CharacterBody2D) and (not is_dead):
		emit_signal("slime_triggered_game_over")
		body.emit_signal("player_hit")  # Notify player of hit
		

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet") and not is_dead:
		area.queue_free()
		$AudioStreamPlayer2D.play()
		is_dead = true
		get_parent().score += 1  #Notify GameManager of score increase
	
