extends CharacterBody2D

signal player_hit  # Signal for when the player is hit by an enemy

@export var move_speed: float = 100
@export var animator: AnimatedSprite2D
@export var bullet_scene: PackedScene

@export var fire_rate: float = 0.5  # Shooting interval (seconds)
@export var bullet_offset: float = 32  # Bullet spawn offset

@export var fire_rate_boost_duration: float = 10.0  # Duration of fire rate boost
@export var fire_rate_boost_amount: float = 0.1  # Amount to reduce fire rate by
var base_fire_rate: float  # Store the default fire rate
var boost_timer: float = 0.0  # Track boost duration
var is_boosted: bool = false  # Track if boost is active

var shoot_timer: float = 0.0  # 自动射击计时器
var can_move: bool = true  # Control player input during game over
var power_up_ui : Control

var pistol_scene = preload("res://Scenes/Weapon.tscn")

func _ready() -> void:
	base_fire_rate = fire_rate  # Store initial fire rate
	power_up_ui = $"../UI/PowerUpUI"
	
	var pistol = pistol_scene.instantiate()
	$WeaponHolder.add_child(pistol)
	
func _process(delta: float) -> void:
	if can_move:
		var angle = get_shoot_direction().angle()
		$AimUI.rotation = angle
		# --- 在 Weapon 实例化后，动态调整其贴图方向 ---
		var weapon = $WeaponHolder.get_node_or_null("Weapon")
		if weapon:
			weapon.rotation = angle
			if animator.flip_h:
				weapon.scale.y = -1
				$WeaponHolder.z_index = -5
			else:
				weapon.scale.y = 1
				$WeaponHolder.z_index = 1
			
		# Update shooting timer
		shoot_timer += delta
		if shoot_timer >= fire_rate:
			_spawn_bullet(get_shoot_direction())
			$FireSound.play()
			shoot_timer = 0.0  # Reset shooting timer

		# Running sound
		if velocity != Vector2.ZERO and not $RunningSound.playing:
			$RunningSound.play()
		elif velocity == Vector2.ZERO:
			$RunningSound.stop()
			
		if is_boosted: 
			boost_timer -= delta
			if boost_timer <= 0:
				is_boosted = false
				fire_rate = base_fire_rate  # Revert to original fire rate
				if power_up_ui: power_up_ui.set_power_up_active("fire_rate", false)
			if power_up_ui:
				power_up_ui.update_fire_rate_timer(boost_timer, fire_rate_boost_duration)

func _physics_process(_delta: float) -> void:
	if can_move:
		velocity = Input.get_vector("Left", "Right", "Up", "Down") * move_speed
		var facing_left = (get_global_mouse_position() - global_position).normalized().x < 0
		animator.flip_h = facing_left
		if animator.flip_h:
			$player/Sprite2D.visible = true
		else:
			$player/Sprite2D.visible = false
		var offset = abs($WeaponHolder.position.x)
		if facing_left:
			$WeaponHolder.position.x =  offset 
		else: $WeaponHolder.position.x = -offset 
		
		if velocity == Vector2.ZERO:
			animator.play("idle")
		else:
			pass
			#animator.play("run")
	else:
		velocity = Vector2.ZERO
		#animator.play("over")
	move_and_slide()

func get_shoot_direction() -> Vector2:
	var direction = (get_global_mouse_position() - global_position).normalized()
	return direction
	
func _spawn_bullet(direction: Vector2) -> void:
	var bullet_node = bullet_scene.instantiate() 
	if not bullet_node:
		push_error("❌ Failed to instantiate bullet!！")
		return
	bullet_node.global_position =  global_position + direction * bullet_offset 
	bullet_node.direction = direction
	bullet_node.rotation = direction.angle()
	get_parent().add_child(bullet_node)

func apply_fire_rate_boost() -> void:
	fire_rate = max(fire_rate - fire_rate_boost_amount, 0.1)  # Apply boost
	is_boosted = true
	boost_timer = fire_rate_boost_duration  # Start boost timer
	if power_up_ui:
		power_up_ui.set_power_up_active("fire_rate", true)

func apply_speed_up() -> void:
	move_speed += 25
	move_speed = clamp(move_speed,100, 250)  # Apply boost

func on_hit() -> void:
	emit_signal("player_hit")
		
func disable_input() -> void:
	can_move = false
