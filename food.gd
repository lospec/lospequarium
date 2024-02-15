extends RigidBody2D

func _process(delta):
	if (self.position.y > 270):
		queue_free()

