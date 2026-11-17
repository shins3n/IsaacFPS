extends Control

@onready var play_button: Button = $Buttons/PlayButton
@onready var quit_button: Button = $Buttons/QuitButton

func _ready() -> void:
	# Показываем курсор мыши в меню
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Подключаем кнопки
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	GameState.reset()  # Сброс прогресса комнат
	get_tree().change_scene_to_file("res://Scenes/Rooms/StartRoom.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
