# DialogueUI.gd (最终修复版 v5.0)
extends CanvasLayer

signal dialogue_finished

@onready var text_label: Label = $Panel/TextLabel

var dialogue_library = {
	"victory_dialogue": [
		"Finally...We've escaped....",
		"Thanks to your help, we are now safe.",
		"Congratulations, victory!"
	]
}

# This variable's type is also changed to a generic Array to match the parameter of the _begin function.
var dialogue_lines: Array = []
var current_line_index: int = 0

func _ready() -> void:
	hide()

func start_dialogue_from_library(key: String) -> void:
	if dialogue_library.has(key):
		var lines_to_show = dialogue_library[key]
		_begin(lines_to_show)
	else:
		push_error("Key not found in dialogue library: " + key)

# The parameter type is a generic Array
func _begin(lines: Array) -> void:
	# Now, assigning a generic Array to another generic Array is completely fine
	dialogue_lines = lines
	current_line_index = 0
	text_label.text = dialogue_lines[current_line_index]
	show()
	get_tree().paused = true # Pause the game when the dialogue starts

func advance_dialogue() -> void:
	current_line_index += 1
	if current_line_index < dialogue_lines.size():
		text_label.text = dialogue_lines[current_line_index]
	else:
		end_dialogue()

func end_dialogue() -> void:
	dialogue_lines.clear()
	hide()
	# We are no longer unpausing here, because we need to keep it paused after victory
	emit_signal("dialogue_finished")

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		advance_dialogue()
