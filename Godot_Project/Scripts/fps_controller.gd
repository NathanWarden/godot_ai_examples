
extends KinematicBody


var g = -9.8
const MAX_SPEED = 5
const JUMP_SPEED = 7
const ACCEL= 2
const DEACCEL= 4
const MAX_SLOPE_ANGLE = 30
var vel = Vector3()
var heading = 0.0
var pitch = 0.0
var headingNode = self
var pitchNode = self
var camera = self

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pitchNode = headingNode.get_node("Pitch")
	camera = pitchNode.get_node("Camera")
	set_process_input(true)
	set_fixed_process(true)


func _input(event):
	if ( event.type == InputEvent.MOUSE_MOTION ):
		var mouseSpeedFactor = 0.00005
		var maxPitch = 0.5
		heading -= event.speed_x * mouseSpeedFactor
		pitch -= event.speed_y * mouseSpeedFactor
		pitch = clamp(pitch,-maxPitch,maxPitch)
		headingNode.set_rotation(Vector3(0,heading,0))
		pitchNode.set_rotation(Vector3(pitch,0,0))


func _fixed_process(delta):
	var dir = Vector3() #where does the player intend to walk to
	var cam_xform = camera.get_global_transform()
	
	if (Input.is_action_pressed("move_forward")):
		dir+=-cam_xform.basis[2] 
	if (Input.is_action_pressed("move_backward")):
		dir+=cam_xform.basis[2] 
	if (Input.is_action_pressed("move_left")):
		dir+=-cam_xform.basis[0] 
	if (Input.is_action_pressed("move_right")):
		dir+=cam_xform.basis[0] 

	dir.y=0
	dir=dir.normalized()

	vel.y+=delta*g
	
	var hvel = vel
	hvel.y=0	
	
	var target = dir*MAX_SPEED
	var accel
	if (dir.dot(hvel) >0):
		accel=ACCEL
	else:
		accel=DEACCEL
		
	hvel = hvel.linear_interpolate(target,accel*delta)
	
	vel.x=hvel.x;
	vel.z=hvel.z

	var motion = move(vel*delta)

	var on_floor = false
	var original_vel = vel


	var floor_velocity=Vector3()

	var attempts=4

	while(is_colliding() and attempts):
		var n=get_collision_normal()

		if ( rad2deg(acos(n.dot( Vector3(0,1,0)))) < MAX_SLOPE_ANGLE ):
				#if angle to the "up" vectors is < angle tolerance
				#char is on floor
				floor_velocity=get_collider_velocity()
				on_floor=true
			
		motion = n.slide(motion)
		vel = n.slide(vel)
		if (original_vel.dot(vel) > 0):
			#do not allow to slide towads the opposite direction we were coming from
			motion=move(motion)
			if (motion.length()<0.001):
				break
		attempts-=1

	if (on_floor):
		if (floor_velocity!=Vector3()):
			move(floor_velocity*delta)

		if (Input.is_action_pressed("jump")):
			vel.y=JUMP_SPEED
