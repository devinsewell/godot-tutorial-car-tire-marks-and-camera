extends KinematicBody

export var gravity = -20.0
export var wheel_base = 0.6
export var steering_limit = 11.0
export var engine_power = 25.0
export var braking = -10.0
export var friction = -0.55
export var drag = -1.5   #OG = 0.5
export var max_speed_reverse = 20.0

onready var b_decal = preload("res://cars/TreadDecal.tscn")

export var slip_speed = 8.0
export var traction_slow = 0.05
export var traction_fast = 0.01

var drifting = false

var acceleration = Vector3.ZERO
var velocity = Vector3.ZERO
var steer_angle = 0.0
var flip_angle = 0.0

func addTireTracks():
	if(drifting == true and steer_angle != 0):
		var b = b_decal.instance()
		get_parent().add_child(b)
		b.global_transform.origin = global_transform.origin
		var r = get_rotation()
		b.set_rotation(r)
	
func _physics_process(delta):
	get_input()
	if is_on_floor():
		apply_friction(delta)
		calculate_steering(delta)
		addTireTracks()
	acceleration.y = gravity
	velocity += acceleration * delta
	
	friction = -0.5 + (velocity.x / 10)
	
	if global_transform.origin.y < -40:
		acceleration = Vector3.ZERO
		velocity = Vector3.ZERO
		global_transform.origin.y = 10
		global_transform.origin.x = 0
		global_transform.origin.z = 0
		
	velocity = move_and_slide_with_snap(velocity, -transform.basis.y, Vector3.UP, true)
	var n = $RayCast.get_collision_normal()
	var xform = align_with_y(global_transform, n)

	if !is_on_floor():
		n = ((Vector3.UP + Vector3.UP) / 2.0).normalized()
	if is_on_floor():
		for i in get_slide_count():
			var c = get_slide_collision(i)
			xform = align_with_y(global_transform, c.normal)
			if Input.is_action_pressed("accelerate") or velocity.y > 0.2 or velocity.y < -0.2:
				global_transform = global_transform.interpolate_with(xform, 0.2)
			
func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform

func apply_friction(delta):
	if velocity.length() < 0.2 and acceleration.length() == 0:
		velocity.x = 0
		velocity.z = 0
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += drag_force + friction_force

func calculate_steering(delta):
	var rear_wheel = transform.origin + transform.basis.z * wheel_base / 2.0
	var front_wheel = transform.origin - transform.basis.z * wheel_base / 2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(transform.basis.y, steer_angle) * delta
	var new_heading = rear_wheel.direction_to(front_wheel)

	# traction
	if not drifting and velocity.length() > slip_speed:
		drifting = true
	if drifting and velocity.length() < slip_speed:
		drifting = false
	var accelerate = Input.is_action_pressed("accelerate")
	var brake = Input.is_action_pressed("brake")
	var traction = traction_fast if drifting else traction_slow
	if velocity.length() > 7 or velocity.length() < -7:
		if traction > 0 and (accelerate or brake):
			traction = traction - 0.005
		else:
			if(traction < traction_slow):
				traction = traction_slow + 0.005

	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		velocity = lerp(velocity, new_heading * velocity.length(), traction)
	#if d < 0:
	#	velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	look_at(transform.origin + new_heading, transform.basis.y)

func get_input():
	# Override this in inherited scripts for controls
	pass
