extends CharacterBody3D

# ============ СИГНАЛЫ ============

signal health_changed(current: int, max_health: int)
## Сигнал испускается при изменении здоровья.
## HUD подписывается на него, чтобы обновлять сердечки.

# ============ НАСТРОЙКИ ДВИЖЕНИЯ ============

@export var move_speed: float = 5.0
## Скорость движения по земле

@export var jump_velocity: float = 4.5
## Начальная скорость прыжка

@export var mouse_sensitivity: float = 0.003
## Чувствительность мыши

# ============ НАСТРОЙКИ ЗДОРОВЬЯ ============

@export var max_health: int = 6
## Максимальное здоровье (в половинках сердечек).
## 6 = 3 полных сердечка.

var current_health: int
## Текущее здоровье

var invulnerability_time: float = 0.0
## Таймер неуязвимости после урона

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
	# Захватываем курсор мыши
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Инициализируем здоровье
	current_health = max_health
	health_changed.emit(current_health, max_health)
	
	# Добавляем в группу "player" — чтобы враги могли нас найти
	add_to_group("player")
	
	# ===== ЗАПЕКАНИЕ НАВИГАЦИИ =====
	# Ждём 2 кадра, чтобы все узлы сцены загрузились
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Ищем NavRegion двумя способами (на случай, если он не в корне сцены)
	var nav_region: NavigationRegion3D = null
	
	# Способ 1: прямой поиск в текущей сцене
	nav_region = get_tree().current_scene.get_node_or_null("NavRegion")
	
	# Способ 2: рекурсивный поиск по всей сцене
	if not nav_region:
		nav_region = _find_navigation_region(get_tree().current_scene)
	
	if nav_region:
		print(" NavRegion найден: ", nav_region.name)
		nav_region.bake_navigation_mesh()
		print(" Навигация запечена")
	else:
		print(" NavRegion НЕ найден в сцене! Проверь имя узла.")

# Вспомогательная функция — рекурсивно ищет NavigationRegion3D
func _find_navigation_region(node: Node) -> NavigationRegion3D:
	if node is NavigationRegion3D:
		return node
	for child in node.get_children():
		var result = _find_navigation_region(child)
		if result:
			return result
	return null

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
	# 0. Уменьшаем таймер неуязвимости
	if invulnerability_time > 0.0:
		invulnerability_time -= delta

	# 1. Гравитация
	if not is_on_floor():
		velocity.y -= gravity * delta

	# 2. Прыжок
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# 3. Движение WASD
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
	var shoot_direction = -camera.global_transform.basis.z
	projectile.direction = shoot_direction.normalized()
	
	# Ждём fire_rate секунд
	await get_tree().create_timer(fire_rate).timeout
	
	# Снова разрешаем стрелять
	can_shoot = true

# ============ УРОН И СМЕРТЬ ============

func take_damage(amount: int) -> void:
	# Если игрок ещё в состоянии неуязвимости — игнорируем урон
	if invulnerability_time > 0.0:
		return
	
	current_health = max(0, current_health - amount)
	health_changed.emit(current_health, max_health)
	
	# Делаем игрока неуязвимым на 1 секунду
	invulnerability_time = 1.0
	
	if current_health <= 0:
		die()

func die() -> void:
	var game_over_scene = preload("res://Scenes/UI/GameOverScreen.tscn")
	var game_over = game_over_scene.instantiate()
	get_tree().root.add_child(game_over)
	
	set_physics_process(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
