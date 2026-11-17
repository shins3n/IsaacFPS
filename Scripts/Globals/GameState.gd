extends Node

# Словарь для хранения зачищенных комнат
var cleared_rooms: Dictionary = {}

func mark_room_cleared(scene_path: String) -> void:
	cleared_rooms[scene_path] = true
	print("✅ Комната помечена как зачищенная: ", scene_path)

func is_room_cleared(scene_path: String) -> bool:
	return cleared_rooms.get(scene_path, false)

func reset() -> void:
	cleared_rooms.clear()
	print("🔄 Прогресс комнат сброшен")
