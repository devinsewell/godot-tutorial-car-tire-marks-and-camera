extends "res://cars/car_base.gd"

func get_input():
	var turn = Input.get_action_strength("steer_left")
	turn -= Input.get_action_strength("steer_right")
	steer_angle = turn * deg2rad(steering_limit)
	if !is_on_floor():
		var r = get_rotation()
		r += (Vector3(0,1,0) * steer_angle*0.3)  
		set_rotation(r)
	$tmpParent/sedanSports/wheel_frontRight.rotation.y = steer_angle*2
	$tmpParent/sedanSports/wheel_frontLeft.rotation.y = steer_angle*2
	acceleration = Vector3.ZERO
	if Input.is_action_pressed("accelerate") && is_on_floor():
			acceleration = -transform.basis.z * engine_power
	if Input.is_action_pressed("brake") && is_on_floor():
			acceleration = -transform.basis.z * braking
