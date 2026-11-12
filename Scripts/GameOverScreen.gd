extends CanvasLayer

@onready var restart_button: Button = $RestartButton

func _ready() -> void:
	# Показываем курсор, чтобы можно было нажать кнопку
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	restart_button.pressed.connect(_on_restart_pressed)

func _on_restart_pressed() -> void:
	# 1. Удаляем этот экран смерти из памяти
	queue_free()
	
	# 2. Перезагружаем комнату
	get_tree().reload_current_scene()
	
	# 3. Ждем один кадр, чтобы новая сцена загрузилась, и захватываем мышь
	await get_tree().process_frame
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
