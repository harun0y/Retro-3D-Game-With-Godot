extends KinematicBody

export var max_speed = 10
export var acceleration = 70
export var friction = 60
export var air_friction = 10
export var gravity = -40
export var jump_impulse = 20
export var mouse_sensitivity = .1
export var controller_sensitivity = 3
export var rot_speed = 5
export var weapon_damage = 20 #daha sonra weapons ayrı scene'e koyulacak.

export (int, 0, 10) var push = 1

var velocity = Vector3.ZERO
var snap_vector = Vector3.ZERO
var rng = RandomNumberGenerator.new()
var dead = false
var frozen = false
onready var spring_arm = $SpringArm
onready var pivot = $Pivot
onready var hitbox = $HitBox
onready var notificationLabel = $playerInfoLabel
onready var alert_area_hearing = $AlertAreaHearing
onready var alert_area_los = $AlertAreaLos
onready var health_manager = $HealthManager


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	health_manager.init()
	health_manager.connect("dead", self, "kill")
	$Pivot/kaolzaogoch2/AnimationPlayer.get_animation("idle").loop = true
	$Pivot/kaolzaogoch2/AnimationPlayer.get_animation("running").loop = true
	$Pivot/kaolzaogoch2/AnimationPlayer.get_animation("crouch idle").loop = true
	$Pivot/kaolzaogoch2/AnimationPlayer.get_animation("crouched walking").loop = true

func _unhandled_input(event):
	if event.is_action_pressed("left_click"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event.is_action_pressed("tab"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		spring_arm.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))


func _physics_process(delta):
	if frozen:
		return
	hitbox.rotation.y = pivot.rotation.y #şimdilik böle
	var input_vector = get_input_vector()
	var direction = get_direction(input_vector)
	apply_movement(input_vector, direction, delta)
	apply_friction(direction, delta)
	apply_gravity(delta)
	update_snap_vector()
	jump()
	crouch()
	walk()
	attack()
	interact()
	apply_controller_rotation()
	spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg2rad(-75), deg2rad(75))
	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, true, 4, 0.785398, false)
	$fps.text = str(Engine.get_frames_per_second())
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("bodies"):
			collision.collider.apply_central_impulse(-collision.normal * velocity.length() * push)
	
	
func get_input_vector():
	var input_vector = Vector3.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	return input_vector.normalized() if input_vector.length() > 1 else input_vector
	
	
func get_direction(input_vector):
	var direction = (input_vector.x * transform.basis.x) + (input_vector.z * transform.basis.z)
	return direction
	
	
func apply_movement(input_vector, direction, delta):
	if direction != Vector3.ZERO:
		velocity.x = velocity.move_toward(direction * max_speed, acceleration * delta).x
		velocity.z = velocity.move_toward(direction * max_speed, acceleration * delta).z
		pivot.rotation.y = lerp_angle(pivot.rotation.y, atan2(-input_vector.x, -input_vector.z), rot_speed * delta)
		
func apply_friction(direction, delta):
	if direction == Vector3.ZERO:
		if is_on_floor():
			velocity = velocity.move_toward(Vector3.ZERO, friction * delta)
		else:
			velocity.x = velocity.move_toward(direction * max_speed, air_friction * delta).x
			velocity.z = velocity.move_toward(direction * max_speed, air_friction * delta).z

func apply_gravity(delta):
	velocity.y += gravity * delta
	velocity.y = clamp(velocity.y, gravity, jump_impulse)

func update_snap_vector():
	snap_vector = -get_floor_normal() if is_on_floor() else Vector3.DOWN

func jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		$AnimationTree.set("parameters/oneShotJump/active", true)
		snap_vector = Vector3.ZERO
		velocity.y = jump_impulse
		
	if Input.is_action_just_released("jump") and velocity.y > jump_impulse / 2:
		velocity.y = jump_impulse / 2

func crouch():
	if Input.is_action_pressed("ctrl") and is_on_floor():
		max_speed = 3
		$AnimationTree.set("parameters/standCrouch/current", 1)
		$AnimationTree.set("parameters/idleCrouch/blend_position", velocity.length())
		$CollisionCrouch.disabled = false # collision kisaltildi
		$CollisionIdle.disabled = true
	else:
		max_speed = 10
		$AnimationTree.set("parameters/standCrouch/current", 0)
		$CollisionCrouch.disabled = true
		$CollisionIdle.disabled = false# collision kisaltildi

func walk():
	if is_on_floor():
		if velocity.length() >= 0:
			$AnimationTree.set("parameters/idleWalk/blend_position", velocity.length())
		else: 
			$AnimationTree.set("parameters/idleWalk/blend_position", 0.01)

func attack():
	if Input.is_action_just_pressed("left_click") and is_on_floor():
		rng.randomize()
		$AnimationTree.set("parameters/attackJump/current", rng.randi_range(0,1))
		$AnimationTree.set("parameters/oneShot/active", true)
		$AttackTimer.start()

func _on_AttackTimer_timeout():
	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("enemies") and body.has_method("hurt"):
			body.hurt(weapon_damage)

func interact():
	for area in hitbox.get_overlapping_areas():
		if area.is_in_group("collectables"):
			area.touched(false)
			if Input.is_action_just_pressed("E"):
				notificationLabel.text = area.info + " alindi!"
				area.touched(true)
				$AnimationPlayer.play("show_info")
				area.die()

func apply_controller_rotation():
	var axis_vector = Vector2.ZERO
	axis_vector.x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	axis_vector.y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	
	if true:
		rotate_y(deg2rad(-axis_vector.x) * controller_sensitivity)
		spring_arm.rotate_x(deg2rad(-axis_vector.y) * controller_sensitivity)

func alert_nearby_enemies():
	var nearby_enemies = alert_area_los.get_overlapping_bodies()
	for nearby_enemy in nearby_enemies:
		if nearby_enemy.has_method("alert"):
			nearby_enemy.alert()
	nearby_enemies = alert_area_hearing.get_overlapping_bodies()
	for nearby_enemy in nearby_enemies:
		if nearby_enemy.has_method("alert"):
			nearby_enemy.alert(false)

func hurt(damage):
	health_manager.hurt(damage)
	print('hit')

func heal(amount):
	health_manager.heal(amount)

func kill():
	dead = true
	$AnimationTree.active = false
	$Pivot/kaolzaogoch2/AnimationPlayer.play("death")
	freeze()
	
func freeze():
	frozen = true

func unfreeze():
	frozen = false
