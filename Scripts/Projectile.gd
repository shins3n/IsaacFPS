extends CharacterBody3D

# ============ НАСТРОЙКИ ============

@export var speed: float = 15.0
## Скорость полёта снаряда

@export var lifetime: float = 3.0
## Сколько секунд снаряд живёт до авто-удаления

var direction: Vector3 = Vector3.FORWARD
## Направление полёта (задаётся из скрипта Player)

# ============ ГОТОВНОСТЬ ============

func _ready() -> void:
	# Удаляем снаряд через lifetime секунд
	await get_tree().create_timer(lifetime).timeout
	queue_free()

# ============ ФИЗИКА ============

func _physics_process(delta: float) -> void:
	# Двигаем снаряд в направлении direction
	# move_and_collide возвращает объект столкновения или null
	var collision := move_and_collide(direction * speed * delta)
	
	if collision:
		# Если во что-то попали — наносим урон (если умеет) и удаляемся
		var body = collision.get_collider()
		if body and body.has_method("take_damage"):
			body.take_damage(1)
		queue_free()
