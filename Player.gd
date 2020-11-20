extends KinematicBody2D

var max_speed = 450
var acceleration = 75
var jump_max_height = 950
var air_friction = 0.9
var gravity = 50

var vel = Vector2()

var jumps_left = 2
var dash_direction = Vector2(1,0)
var can_dash = false
var dashing = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	run(delta)
	jump()
	dash()
	friction()
	handle_gravity()
	handle_textures()
	vel = move_and_slide(vel, Vector2.UP)


func run(delta):
	if Input.is_action_pressed("ui_right"):
		vel.x = min(vel.x + acceleration, max_speed)
		$Sprite.flip_h = false
	elif Input.is_action_pressed("ui_left"):
		vel.x = max(vel.x - acceleration, -max_speed)
		$Sprite.flip_h = true
		


func jump():
	# I can jump when I'm on floor or next to the wall
	if is_on_floor() or next_to_wall():
		jumps_left = 2 # Recharge double-jump. 

	if Input.is_action_just_pressed("ui_up") and jumps_left > 0:
		if vel.y > 0: vel.y = 0 # if I'm falling - ignore fall velocity
		vel.y -= jump_max_height 
		jumps_left -= 1

		# Jump away from the wall
		if not is_on_floor() and next_to_left_wall() and Input.is_action_pressed("ui_left"):
			vel.x += jump_max_height
		if not is_on_floor() and next_to_right_wall() and Input.is_action_pressed("ui_right"):
			vel.x -= jump_max_height 

	# If I'm still going up and have released the jump button - cut off the jump and start falling down
	if Input.is_action_just_released("ui_up") and vel.y < 0:
		vel.y = lerp(vel.y, 0, 0.6)
		


func friction():
	# When I hold the key
	var running = Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")
	
	if not running:
		if is_on_floor():
			vel.x = lerp(vel.x, 0, 0.8) #friction to stop on ground
		else: 
			vel.x = lerp(vel.x, 0, 0.2) # better control in the air if no button pressed
		
	if not is_on_floor():
		vel.x *= air_friction # slower in the air
	

func handle_gravity():
	if not dashing:
		vel.y += gravity
		if vel.y > 1400: 
			vel.y = 1400# terminal velocity
	
	var can_wall_slide = next_to_left_wall() and Input.is_action_pressed("ui_left") or next_to_right_wall() and Input.is_action_pressed("ui_right")
	
	if can_wall_slide: 
		if vel.y > 100:
			vel.y = 100 # wall slide
	if Input.is_action_pressed("ui_down"):
		vel.y = 800


func dash():
	if is_on_floor():
		can_dash = true # recharges when player touches the floor
	
	dash_direction = Vector2()
	if Input.is_action_pressed("ui_down"):
		dash_direction.y = 1
	if Input.is_action_pressed("ui_up"):
		dash_direction.y = -1
	if Input.is_action_pressed("ui_right"):
		dash_direction.x = 1
	if Input.is_action_pressed("ui_left"):
		dash_direction.x = -1


	if Input.is_action_just_pressed("ui_select") and can_dash:
		vel = dash_direction.normalized() * 5000
		can_dash = false
		dashing = true # turn off gravity while dashing
		yield(get_tree().create_timer(0.2), "timeout")
		dashing = false


func next_to_wall():
	return next_to_left_wall() or next_to_right_wall()

func next_to_left_wall():
	return $LeftWallRaycast1.is_colliding() or $LeftWallRaycast2.is_colliding()

func next_to_right_wall():
	return $RightWallRaycast1.is_colliding() or $RightWallRaycast2.is_colliding()


func handle_textures():
	var running = Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")
	if is_on_floor():
		if running:
			$Sprite.play("Run")
		else:
			$Sprite.play("Idle")
	else: 
		if vel.y < 0:
			$Sprite.play("Jump")
		else:
			$Sprite.play("Fall")
	if can_dash == false:
		 $Sprite.play("Idle")


















