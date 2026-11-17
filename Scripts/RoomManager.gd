extends Node3D

func _ready() -> void:
	var current_path = scene_file_path
	
	# Если комната уже зачищена — удаляем врагов
	if GameState.is_room_cleared(current_path):
		print("🟢 Комната уже зачищена. Удаляем врагов.")
		
		# Ищем врагов по имени "Enemy" (или содержащим "Enemy")
		for child in get_children():
			if child.name == "Enemy":
				child.queue_free()
