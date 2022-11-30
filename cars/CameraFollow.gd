extends Camera

export(NodePath) var cameraPivotPath
export(NodePath) var objectToFollowPath

onready var cameraPivot = get_node(cameraPivotPath)
onready var objectToFollow = get_node(objectToFollowPath)


var rotationSpeed = 4
var mouseSensi = 0.1
export var camAccel = 5 # Speed With Which The Camera Follows Up The Player (Not Need When Not using the `linear_interpolate` function

var mouseCaptured = true


#func _input(event):
	#if (event is InputEventMouseMotion and mouseCaptured == true):
		#self.rotate_y(deg2rad(-event.relative.x * mouseSensi))


func _process(delta):
	cameraPivot.translation = cameraPivot.translation.linear_interpolate(objectToFollow.translation, delta * camAccel)
	
