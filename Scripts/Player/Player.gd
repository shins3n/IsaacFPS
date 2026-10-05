extends CharacterBody3D

# ============ НАСТРОЙКИ ДВИЖЕНИЯ ============

@export var move_speed: float = 5.0
## Скорость движения по земле

@export var jump_velocity: float = 4.5
## Начальная скорость прыжка

@export var mouse_sensitivity: float = 0.003
## Чувствительность мыши

# ============ ССЫЛКИ НА УЗЛЫ ============

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var muzzle: Node3D = $Muzzle

# ============ ГРАВИТАЦИЯ ============

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# ============ ПРЕДЗАГРУЗКА СНАРЯДА ============

const PROJECTILE_SCENE = preload("res://Projectiles/Projectile.tscn")

# ============ НАСТРОЙКИ СТРЕЛЬБЫ ============

@export var fire_rate: float = 0.3
## Задержка между выстрелами (в секундах)

var can_shoot: bool = true
## Флаг: можно ли сейчас стрелять

# ============ ГОТОВНОСТЬ ============

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# ============ ВВОД ============

func _unhandled_input(event: InputEvent) -> void:
	# --- Поворот камеры мышью ---
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

	# --- Escape освобождает курсор ---
	if event.is_action_pressed("pause"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# ============ ФИЗИКА ============

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir: Vector2 = Input.get_vector(
		"move_left", "move_right",
		"move_forward", "move_back"
	)
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)

	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

	move_and_slide()
	# 4. Стрельба
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

	# 5. Применяем движение
	move_and_slide()

# ============ СТРЕЛЬБА ============

func shoot() -> void:
	# Блокируем возможность стрелять
	can_shoot = false
	
	# Создаём экземпляр снаряда из сцены
	var projectile = PROJECTILE_SCENE.instantiate()
	
	# Добавляем снаряд в текущий мир (на сцену)
	get_tree().root.add_child(projectile)
	
	# Позиционируем снаряд в точке Muzzle
	projectile.global_position = muzzle.global_position
	
	# Задаём направление — куда смотрит камера
	# -camera.global_transform.basis.z — это вектор "вперёд" камеры
	var shoot_direction = -camera.global_transform.basis.z
	projectile.direction = shoot_direction.normalized()
	
	# Ждём fire_rate секунд
	await get_tree().create_timer(fire_rate).timeout
	
	# Снова разрешаем стрелять
	can_shoot = true
