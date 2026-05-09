extends Control
signal stress_removed(amount)
@onready var full_cup = $Sprite2D
@onready var empty_cup = $Sprite2D2
@onready var coffee_button = $TextureButton
@onready var coffee_bar = $ProgressBar
@onready var coffee_label = $Label
var coffee_amount := 100.0
const COFFEE_USE_AMOUNT := 25.0
const STRESS_REMOVE_AMOUNT := 20.0

func _ready() -> void:
	empty_cup.visible = false
	full_cup.visible = true
	coffee_bar.min_value = 0
	coffee_bar.max_value = 100
	update_bar()

func _on_texture_button_pressed() -> void:
	if coffee_amount <= 0:
		return
	coffee_amount -= COFFEE_USE_AMOUNT
	coffee_amount = clamp(coffee_amount, 0, 100)
	stress_removed.emit(STRESS_REMOVE_AMOUNT)
	update_bar()

func update_bar():
	coffee_bar.value = coffee_amount
	coffee_label.text = tr("COFFEE") + str(int(coffee_amount)) + "%"
	full_cup.visible = coffee_amount > 0
	empty_cup.visible = coffee_amount <= 0
	var style = StyleBoxFlat.new()
	if coffee_amount > 60:
		style.bg_color = Color.GREEN
	elif coffee_amount > 30:
		style.bg_color = Color.ORANGE
	else:
		style.bg_color = Color.RED
	coffee_bar.add_theme_stylebox_override("fill", style)
