extends CharacterBody3D

# ============ НАСТРОЙКИ (можно менять в Инспекторе) ============

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

# ============ ГОТОВНОСТЬ ============

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# ============ ВВОД ============

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

	if event.is_action_pressed("pause"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# ============ ФИЗИКА ============

func _physics_process(delta: float) -> void:
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

	# 4. Применить движение
	move_and_slide()
