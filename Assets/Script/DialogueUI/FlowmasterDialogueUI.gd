# DialogueUI.gd (最终修复版 v5.0)
extends CanvasLayer

signal dialogue_finished

@onready var text_label: Label = $Panel/TextLabel

var dialogue_library = {
	"victory_dialogue": [
		"太好了，你成功到达了这里！3",
		"感谢你的帮助，我们终于安全了。3",
		"恭喜你获得了胜利！3"
	]
}

# --- 核心修改在这里 ---
# 我们把这个变量的类型也改成了通用的 Array，以匹配_begin函数的参数
var dialogue_lines: Array = []
var current_line_index: int = 0

func _ready() -> void:
	hide()

func start_dialogue_from_library(key: String) -> void:
	if dialogue_library.has(key):
		var lines_to_show = dialogue_library[key]
		_begin(lines_to_show)
	else:
		push_error("对话库中找不到key: " + key)

# 参数类型是通用的 Array
func _begin(lines: Array) -> void:
	# 现在，把一个通用Array赋值给另一个通用Array，完全没有问题
	dialogue_lines = lines
	current_line_index = 0
	text_label.text = dialogue_lines[current_line_index]
	show()
	get_tree().paused = true # 对话开始时暂停游戏

func advance_dialogue() -> void:
	current_line_index += 1
	if current_line_index < dialogue_lines.size():
		text_label.text = dialogue_lines[current_line_index]
	else:
		end_dialogue()

func end_dialogue() -> void:
	dialogue_lines.clear()
	hide()
	# 注意：我们在这里不再 unpause，因为胜利后需要保持暂停
	# get_tree().paused = false # 暂时注释掉或删除这行
	emit_signal("dialogue_finished")

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		advance_dialogue()
