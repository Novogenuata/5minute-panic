extends PointLight2D

@export var base_energy := 0.12
@export var flicker_strength := 0.06
@export var flicker_speed := 1.8

var target_energy := 0.15
var flicker_timer := 0.0

func _ready():
	energy = base_energy
	target_energy = base_energy

func _process(delta):
	flicker_timer -= delta

	# occasionally choose a new subtle brightness target
	if flicker_timer <= 0.0:
		flicker_timer = randf_range(0.04, 0.18)

		target_energy = base_energy + randf_range(
			-flicker_strength,
			flicker_strength
		)

	# smooth transition instead of harsh jitter
	energy = lerp(
		energy,
		target_energy,
		delta * flicker_speed * 8.0
	)
