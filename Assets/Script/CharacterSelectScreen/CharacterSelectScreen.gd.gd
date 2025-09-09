extends Control

# 之前定义好的角色数据
const CHARACTERS_DATA = {
	"Flyman": {
		"name": "Flyman",
		"description": "The origin of all things, the pioneer of stories.",
		"texture_path": "res://assets/sprites/knight_display.png", # 用于在选择界面展示的大图
		"scene_path": "res://Assets/Scenes/PlayerController/FlymanPlayer.tscn"      # 角色实际的游戏场景
	},
	"Destroyer": {
		"name": "Destroyer",
		"description": "The Mighty Assassin.",
		"texture_path": "res://assets/sprites/wizard_display.png",
		"scene_path": "res://Assets/Scenes/PlayerController/DestroyerPlayer.tscn"
	},
	"Racer": {
		"name": "Racer",
		"description": "Noble Knight, Master of Speed.",
		"texture_path": "res://assets/sprites/rogue_display.png",
		"scene_path": "res://Assets/Scenes/PlayerController/RacerPlayer.tscn"
	},
	"Flowmaster": {
		"name": "Flowmaster",
		"description": "The Omniscient and Omnipotent Mage.",
		"texture_path": "res://assets/sprites/rogue_display.png",
		"scene_path": "res://Assets/Scenes/PlayerController/FlowmasterPlayer.tscn"
	}
}

# 将角色ID（字典的键）存储在一个数组中，方便索引
var character_keys: Array = []
var current_character_index: int = 0

# 引用UI节点，以便在代码中操作它们
@onready var character_viewport: SubViewport = $MarginContainer/VBoxContainer/HBoxContainer/CharacterDisplayPanel/SubViewportContainer/CharacterViewport
@onready var name_label: Label = $MarginContainer/VBoxContainer/NameLabel
@onready var description_label: Label = $MarginContainer/VBoxContainer/DescriptionLabel
@onready var next_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/NextButton
@onready var previous_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/PreviousButton
@onready var select_button: Button = $MarginContainer/VBoxContainer/SelectButton


func _ready() -> void:
	# 获取所有角色的键
	character_keys = CHARACTERS_DATA.keys()

	# 连接按钮的 "pressed" 信号到处理函数
	next_button.pressed.connect(_on_next_button_pressed)
	previous_button.pressed.connect(_on_previous_button_pressed)
	select_button.pressed.connect(_on_select_button_pressed)

	# 初始化显示第一个角色
	update_character_display()


# 更新所有UI元素以显示当前选择的角色
func update_character_display() -> void:
	# --- Start: 清除旧的角色实例 ---
	# 遍历 SubViewport 的所有子节点并删除它们
	for child in character_viewport.get_children():
		child.queue_free() # 使用 queue_free() 是安全的删除方式
	# --- End: 清除旧的角色实例 ---

	# 1. 获取当前角色的ID（例如 "knight"）
	var current_key = character_keys[current_character_index]

	# 2. 从字典中获取该角色的数据
	var current_data = CHARACTERS_DATA[current_key]

	# 3. 更新文本标签
	name_label.text = current_data["name"]
	description_label.text = current_data["description"]

	# --- Start: 实例化新的角色到 SubViewport ---
	# 4. 加载角色场景资源
	var character_scene = load(current_data["scene_path"])
	if character_scene:
		var character_instance = character_scene.instantiate()
		
		# --- 核心改动在这里 ---
		# 检查角色是否有我们定义的接口函数，有就调用它
		if character_instance.has_method("enter_ui_mode"):
			character_instance.enter_ui_mode()
		else:
			print("警告: 角色 ", character_instance.name, " 没有实现 enter_ui_mode() 函数!")
			
		character_viewport.add_child(character_instance)
		character_instance.position = character_viewport.size / 2
	# --- End: 实例化新的角色到 SubViewport ---


# “下一个”按钮被按下时调用
func _on_next_button_pressed() -> void:
	current_character_index += 1
	# 如果索引超出范围，则循环回到第一个
	if current_character_index >= character_keys.size():
		current_character_index = 0

	update_character_display()


# “上一个”按钮被按下时调用
func _on_previous_button_pressed() -> void:
	current_character_index -= 1
	# 如果索引小于0，则循环回到最后一个
	if current_character_index < 0:
		current_character_index = character_keys.size() - 1

	update_character_display()


# “选择”按钮被按下时调用
func _on_select_button_pressed() -> void:
	# 1. 获取选定角色的数据
	var selected_key = character_keys[current_character_index]
	var selected_character_data = CHARACTERS_DATA[selected_key]

	# 2. 将选择的角色场景路径保存到全局状态管理器中
	# (我们将在下一步创建这个 GlobalState)
	GlobalState.selected_character_scene_path = selected_character_data["scene_path"]

	# 3. 打印确认信息并切换到游戏主场景
	print("选择了角色: ", selected_character_data["name"])
	get_tree().change_scene_to_file("res://scenes/main_game.tscn") # 替换成你的游戏场景路径
	

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/Global/start_page.tscn")
