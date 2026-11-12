extends CanvasLayer

@onready var hearts_container: HBoxContainer = $HeartsContainer

func _ready() -> void:
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_signal("health_changed"):
		player.health_changed.connect(_on_health_changed)
		_on_health_changed(player.current_health, player.max_health)

func _on_health_changed(current: int, max_hp: int) -> void:
	for child in hearts_container.get_children():
		child.queue_free()
	
	var total_hearts = int(max_hp / 2.0)
	var full_hearts = int(current / 2.0)
	var half_heart = current % 2 == 1
	
	for i in range(full_hearts):
		_add_heart("♥", Color.RED)
	
	if half_heart:
		_add_heart("♥", Color(1, 0.5, 0.5))
	
	var empty_hearts = total_hearts - full_hearts - (1 if half_heart else 0)
	for i in range(empty_hearts):
		_add_heart("♡", Color.DARK_GRAY)

func _add_heart(symbol: String, color: Color) -> void:
	var label = Label.new()
	label.text = symbol
	label.add_theme_font_size_override("font_size", 40)
	label.add_theme_color_override("font_color", color)
	hearts_container.add_child(label)
