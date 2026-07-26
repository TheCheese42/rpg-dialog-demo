extends Control

@onready var camera: Camera2D = $Camera2D
@onready var dog: AnimatedSprite2D = $Dog
@onready var duck: AnimatedSprite2D = $Duck
@onready var bomb: AnimatedSprite2D = $Bomb
@onready var explosion: AnimatedSprite2D = $Explosion

var _dialog_popup_scene: PackedScene = preload("res://scenes/dialog_popup.tscn")
var _screen_dialog_scene: PackedScene = preload("res://scenes/screen_dialog.tscn")
var _dialog_popup: DialogPopup = null
var _screen_dialog: ScreenDialog = null


func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

	var speakers: Dictionary[String, SpeakerMeta] = {
		"": SpeakerMeta.new("", preload("uid://6356xj1pov2x")),
		"dog": SpeakerMeta.new(
			"Dog", preload("uid://u1whq3as2xjy"),
			preload("res://assets/textures/portraits/dog/dog.png"),
		),
		"duck": SpeakerMeta.new(
			"Duck", preload("res://assets/vocals/female_standard_4.ogg"),
			preload("res://assets/textures/portraits/duck/duck.png"),
			preload("res://assets/scribble1.ttf"),
		)
	}

	var box: DialogBox = create_screen_dialog()
	box.init(
		{"Default": {
			"color": Color.WHITE, "speed": 100, "wave_intensity": 0,
			"wave_speed": 0, "shake_intensity": 0, "shake_speed": 0,
		}}, {}, {}, {}, speakers,
	)
	await box.execute_text("Welcome to RPG Dialog Demo (Press ENTER).", "", "Default")
	await box.execute_text(
		"This is used to showcase the awesome features of RPG Dialog Display.", "", "Default"
	)
	await box.execute_text("Let's introduce you to your new mentor.", "", "Default")
	remove_screen_dialog()

	var tween: Tween = create_tween()
	tween.tween_property(dog, "global_position", Vector2(
		camera.global_position.x, dog.global_position.y), 8.0)
	await tween.finished

	var dialog: DialogFile = preload("res://assets/dialogs/en_US.tres")
	box = create_dialog_popup()
	box.init(
		dialog.presets, dialog.color_presets,
		dialog.speed_presets, dialog.delay_presets, speakers,
	)
	var reader := ConversationReader.new(
		box,
		DialogFile.Conversation.from_dict(dialog.conversations[0]) as DialogFile.Conversation,
	)
	reader.call_script = dog_introduction_scripts.bind(reader, box)
	await reader.execute_conversation()
	await get_tree().create_timer(5.0).timeout

	box = create_screen_dialog()
	box.init(
		{"Default": {
			"color": Color.WHITE, "speed": 100, "wave_intensity": 0,
			"wave_speed": 0, "shake_intensity": 0, "shake_speed": 0,
		}}, {}, {}, {}, speakers,
	)
	await box.execute_text("That was RPG Dialog Demo.\nPress Enter to restart.\nOr Escape to quit.", "", "Default")
	remove_screen_dialog()
	get_tree().change_scene_to_file("res://scenes/demo.tscn")


func dog_introduction_scripts(id: String, reader: ConversationReader, box: DialogBox) -> bool:
	match id:
		"EARTHQUAKE":
			await get_tree().create_timer(0.5).timeout
			var tween: Tween = create_tween()
			tween.set_loops(3)
			tween.tween_property(camera, "offset", Vector2(-10, 5), 0.05)
			tween.tween_property(camera, "offset", Vector2(10, -5), 0.05)
			tween.tween_property(camera, "offset", Vector2.ZERO, 0.05)
			tween.tween_property(camera, "offset", Vector2.ZERO, 1.0)
			await tween.finished
		"DUCK_ENTER":
			var tween: Tween = create_tween()
			tween.tween_property(duck, "global_position", Vector2(
				camera.global_position.x + 160, duck.global_position.y
			), 4.0)
			await tween.finished
			duck.stop()
		"DUCK_WALK_START":
			duck.play("default")
		"DUCK_WALK_STOP":
			duck.stop()
		"CHECK_SKIPPED":
			if box.last_was_skipped:
				await reader.execute_from_page("PRESSED_SHIFT")
				return true
		"DUCK_LEAVE":
			duck.play("default")
			var tween: Tween = create_tween()
			tween.tween_property(duck, "global_position", Vector2(
				camera.get_viewport_rect().end.x + 40, duck.global_position.y
			), 6.0)
			await tween.finished
			duck.stop()
		"DUCK_PEEK":
			duck.rotation_degrees = -25
			var tween: Tween = create_tween()
			tween.tween_property(duck, "global_position", Vector2(
				camera.get_viewport_rect().end.x + 10, duck.global_position.y
			), 1.0)
			await tween.finished
		"DUCK_HIDE":
			var tween: Tween = create_tween()
			tween.tween_property(duck, "global_position", Vector2(
				camera.get_viewport_rect().end.x + 40, duck.global_position.y
			), 1.0)
			tween.finished.connect(func() -> void: duck.rotation_degrees = 0)
		"BOMB":
			var tween: Tween = create_tween()
			tween.tween_property(bomb, "global_position", dog.global_position, 0.5)
			await tween.finished
			bomb.visible = false
			dog.visible = false
			explosion.visible = true
			explosion.play()
			await explosion.animation_finished
			explosion.visible = false
	return false


func create_dialog_popup() -> DialogBox:
	remove_dialog_popup()
	var dialog_popup: DialogPopup = _dialog_popup_scene.instantiate()
	_dialog_popup = dialog_popup
	add_child(dialog_popup)
	return dialog_popup.box


func remove_dialog_popup() -> void:
	if _dialog_popup:
		_dialog_popup.queue_free()


func create_screen_dialog() -> DialogBox:
	remove_screen_dialog()
	var screen_dialog: ScreenDialog = _screen_dialog_scene.instantiate()
	_screen_dialog = screen_dialog
	add_child(screen_dialog)
	return screen_dialog.box


func remove_screen_dialog() -> void:
	if _screen_dialog:
		_screen_dialog.queue_free()


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
