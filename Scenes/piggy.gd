extends Control

@onready var oink = $AudioStreamPlayer2D
@onready var piggy_button = $TextureButton






func _on_texture_button_pressed():
	oink.play()
