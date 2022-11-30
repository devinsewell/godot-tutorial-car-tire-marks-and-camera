extends Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
	scale.x = 0.1
	scale.y = 0.1
	scale.z = 0.1
	pass # Replace with function body.

func _on_Timer_timeout():
	queue_free()
##func process

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
