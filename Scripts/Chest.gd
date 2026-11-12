extends Area3D

@onready var mesh: MeshInstance3D = $MeshInstance3D

var player_in_range: bool = false
var is_opened: bool = false

func _ready() -> void:
	# Подключаем сигналы входа/выхода
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("take_damage"):  # проверка, что это Player
		player_in_range = true
		print("💡 Игрок у сундука. Нажми E")

func _on_body_exited(body: Node3D) -> void:
	if body.has_method("take_damage"):
		player_in_range = false

func _process(_delta: float) -> void:
	# Проверяем нажатие E, только если игрок рядом и сундук ещё не открыт
	if player_in_range and not is_opened and Input.is_key_pressed(KEY_E):
		open_chest()

func open_chest() -> void:
	is_opened = true
	print("🎁 Сундук открыт! Ты получил предмет: +Скорострельность")
	
	# Меняем цвет на золотой (визуальный отклик)
	if mesh:
		var mat = mesh.get_active_material(0)
		if mat and mat is StandardMaterial3D:
			mat.albedo_color = Color(1.0, 0.84, 0.0)
	
	# Находим игрока и ускоряем стрельбу
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.fire_rate = 0.1  # было 0.3 — теперь стреляет в 3 раза быстрее!
		print("🐛 Fire rate игрока теперь: ", player.fire_rate)
