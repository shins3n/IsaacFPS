extends CharacterBody3D

@export var speed: float = 3.0
@export var damage: float = 1.0
@export var max_health: int = 3
@export var attack_cooldown: float = 1.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var mesh: MeshInstance3D = $MeshInstance3D

var player: Node3D
var current_health: int
var attack_timer: float = 0.0
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	print("Враг стартовал")
	current_health = max_health
	player = get_tree().get_first_node_in_group("player")
	
		# Принудительно ставим врага над полом
	global_position.y = 2.0
	velocity.y = 0.0
	print(" Враг принудительно на Y=2, сейчас Y=", global_position.y)
	
	if player:
		print(" Игрок найден: ", player.name)
	else:
		print(" ИГРОК НЕ НАЙДЕН! Нужно add_to_group('player') в Player.gd")
	
	# Ждём, пока навигация запечётся
	await get_tree().create_timer(1.5).timeout
	
	if player:
		nav_agent.target_position = player.global_position
		print("🐛 Цель: ", nav_agent.target_position)


	print("🐛 ПОЗИЦИЯ: global=", global_position, " local=", position)
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if attack_timer > 0.0:
		attack_timer -= delta
	
	if player and nav_agent:
		if nav_agent.is_navigation_finished():
			nav_agent.target_position = player.global_position
		
		var next_pos: Vector3 = nav_agent.get_next_path_position()
		
		# Отладка — раз в секунду
		if Engine.get_physics_frames() % 60 == 0:
			print(" Враг: ", global_position, " | Следующая точка: ", next_pos)
		
		var direction: Vector3 = global_position.direction_to(next_pos)
		direction.y = 0
		
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		var distance = global_position.distance_to(player.global_position)
		if distance < 1.5 and attack_timer <= 0.0:
			attack_timer = attack_cooldown
			if player.has_method("take_damage"):
				player.take_damage(int(damage))
	
	move_and_slide()

func take_damage(amount: int) -> void:
	current_health -= amount
	print(" Враг получил урон. HP: ", current_health)
	if current_health <= 0:
		die()

func die() -> void:
	print(" Враг убит!")
	queue_free()
