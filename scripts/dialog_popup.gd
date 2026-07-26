class_name DialogPopup
extends MarginContainer

var box: DialogBox
var _dialog_box_scene: PackedScene = preload("res://addons/rpg_dialog_display/dialog_box.tscn")
var _old_height: float
var _is_resizing: bool = false

@onready var panel_container: PanelContainer = $PanelContainer


func _ready() -> void:
	box = _dialog_box_scene.instantiate()
	panel_container.add_child(box)
	box.visibility_changed.connect(func() -> void: visible = box.visible)
	_old_height = size.y


func _on_resized() -> void:
	if _is_resizing:
		return
	_is_resizing = true
	var new_height: float = size.y
	custom_maximum_size.y = _old_height
	var resize_tween: Tween = create_tween()
	resize_tween.tween_property(self, "custom_maximum_size:y", new_height, 0.2)
	await resize_tween.finished
	custom_maximum_size.y = -1.0
	_old_height = new_height
	_is_resizing = false
