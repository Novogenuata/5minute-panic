extends Control
signal stress_added(amount)
@onready var sprite = $AnimatedSprite2D
@onready var label = $Label
@onready var notif_sound = $AudioStreamPlayer2D
var active := false
var active_time := 0.0
const STRESS_PER_SECOND := 1.2
const IGNORED_STRESS_PENALTY := 10.0
const IGNORE_LIMIT := 6.0

var notification_keys = [
	"NOTIF_1",
	"NOTIF_2",
	"NOTIF_3",
	"NOTIF_4",
	"NOTIF_5",
	"NOTIF_6",
	"NOTIF_7",
	"NOTIF_8",
	"NOTIF_9"
]

func _ready():
	label.visible = false
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = Vector2(170, 90)
	sprite.play("Idle")

func _process(delta):
	if active:
		active_time += delta
		stress_added.emit(STRESS_PER_SECOND * delta)
		if active_time >= IGNORE_LIMIT:
			stress_added.emit(IGNORED_STRESS_PENALTY)
			clear_notification()

func show_notification():
	if active:
		return
	active = true
	active_time = 0.0
	notif_sound.play()
	label.visible = true
	label.modulate.a = 1.0
	label.size = Vector2(170, 90)
	label.text = tr(notification_keys.pick_random())
	var safe_left := 40.0
	var safe_top := 80.0
	var safe_right = size.x - label.size.x - 40.0
	var safe_bottom = size.y - label.size.y - 80.0
	label.position = Vector2(
		randf_range(safe_left, safe_right),
		randf_range(safe_top, safe_bottom)
	)
	sprite.play("Shake")

func clear_notification():
	active = false
	active_time = 0.0
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 0.25)
	sprite.stop()
	sprite.play("Idle")
	await tween.finished
	label.visible = false

func _on_phone_button_pressed() -> void:
	print("PHONE CLICKED")
	if active:
		clear_notification()
