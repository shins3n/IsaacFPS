extends CanvasLayer

@onready var resume_button: Button = $Buttons/ResumeButton
@onready var menu_button: Button = $Buttons/MenuButton

func _ready() -> void:
	# Показываем курсор и ставим игру на паузу
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	
	resume_button.pressed.connect(_on_resume_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

func _on_resume_pressed() -> void:
	# Снимаем паузу, прячем курсор, удаляем меню паузы
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	queue_free()

func _on_menu_pressed() -> void:
	get_tree().paused = false
	queue_free()
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")
