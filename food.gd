extends RigidBody2D

@export var value = 3000

func _process(delta):
	$AnimatedSprite2D.speed_scale = linear_velocity.y / 20
	if (self.position.y > 270):
		queue_free()
