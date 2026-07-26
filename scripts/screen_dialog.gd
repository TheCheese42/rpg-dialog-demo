class_name ScreenDialog
extends CanvasLayer

@onready var margin_container: MarginContainer = $MarginContainer

var box: DialogBox
var _dialog_box_scene: PackedScene = preload("res://addons/rpg_dialog_display/dialog_box.tscn")


func _ready() -> void:
	box = _dialog_box_scene.instantiate()
	margin_container.add_child(box)
	box.star_character = ""
	box.line_alignment = FlowContainer.AlignmentMode.ALIGNMENT_CENTER
	box.permanently_disable_skip = true
