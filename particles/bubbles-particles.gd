extends GPUParticles2D

var rng = RandomNumberGenerator.new()

func _ready():
	get_node("Timer").start(rng.randf_range(0, 30))
	
func _on_timer_timeout():
	print('timeout')
	emitting = true
