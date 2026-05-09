extends Control
@onready var phone = $Phone
@onready var paper = $Paper
@onready var stress_bar = $UI/StressBar
@onready var stress_label = $UI/StresLabel
@onready var timer_label = $UI/TimeLabel
@onready var coffee = $coffee
@onready var stress_overlay = $StressOverlay
@onready var heartbeat = $Heartbeat
@onready var cursor = $handpencil
@onready var phone_button = $Phone/PhoneButton
@onready var coffee_button = $coffee/TextureButton
var stress := 0.0
var game_time := 0.0
var game_over_state := false
var time_left := 300.0
var phone_min_delay := 7.0
var phone_max_delay := 12.0
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	cursor.play("Pencil")
	phone_button.mouse_entered.connect(_show_hand_cursor)
	phone_button.mouse_exited.connect(_show_pencil_cursor)
	coffee_button.mouse_entered.connect(_show_hand_cursor)
	coffee_button.mouse_exited.connect(_show_pencil_cursor)
	paper.wrong_key.connect(_on_paper_wrong_key)
	paper.essay_finished.connect(_on_essay_finished)
	phone.stress_added.connect(add_stress)
	coffee.stress_removed.connect(remove_stress)
	update_stress_ui()
	update_timer_ui()
	phone_notification_loop()
func _process(delta):
	cursor.global_position = get_global_mouse_position()
	if game_over_state:
		return
	game_time += delta
	time_left -= delta
	if time_left <= 0:
		time_left = 0
		game_over()
	update_timer_ui()
	phone_min_delay = max(1.5, 7.0 - game_time / 35.0)
	phone_max_delay = max(3.0, 12.0 - game_time / 25.0)
	if time_left <= 60:
		timer_label.modulate = Color.RED
func _show_hand_cursor():
	cursor.play("Hand")
func _show_pencil_cursor():
	cursor.play("Pencil")
func phone_notification_loop():
	while not game_over_state:
		var wait_time = randf_range(phone_min_delay, phone_max_delay)
		await get_tree().create_timer(wait_time).timeout
		if game_over_state:
			return
		phone.show_notification()
func _on_paper_wrong_key():
	add_stress(5)
func remove_stress(amount):
	stress -= amount
	stress = clamp(stress, 0, 100)
	update_stress_ui()
func add_stress(amount):
	if game_over_state:
		return
	stress += amount
	stress = clamp(stress, 0, 100)
	update_stress_ui()
	if stress >= 100:
		game_over()
func update_stress_ui():
	stress_bar.value = stress
	stress_label.text = tr("STRESS") + str(int(stress)) + "%"
	if stress_overlay.material:
		var subtle_amount = clamp(stress / 100.0, 0.0, 1.0) * 0.18
		stress_overlay.material.set_shader_parameter("stress_amount", subtle_amount)
	if stress >= 70:
		if not heartbeat.playing:
			heartbeat.play()
	else:
		if heartbeat.playing:
			heartbeat.stop()
func update_timer_ui():
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60
	timer_label.text = tr("TIME_LEFT") + str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)
func game_over():
	game_over_state = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if heartbeat.playing:
		heartbeat.stop()
	print("YOU LOST")
	SceneManager.change_scene("res://Scenes/Fail.tscn")
func _on_essay_finished():
	game_over_state = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if heartbeat.playing:
		heartbeat.stop()
	print("YOU WIN")
	SceneManager.change_scene("res://Scenes/win.tscn")
