extends Area3D

@export var target_scene: String = ""
## Путь к сцене, куда ведёт дверь (задаётся в Инспекторе)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	# Только для игрока
	if not body.has_method("take_damage"):
		return
	if target_scene == "":
		print("⚠️ Дверь без target_scene")
		return
	
	print("🚪 Переход в: ", target_scene)
	get_tree().change_scene_to_file(target_scene)
