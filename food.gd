extends RigidBody2D

@export var value = 3000

func _process(delta):
	if (self.position.y > 270):
		queue_free()

