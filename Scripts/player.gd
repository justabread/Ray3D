extends KinematicBody
class_name Player
var score = 0

#physics
var movSpeed = 2.0
var gravity = 12.0

#camera
var minLookAngle = -90.0
var maxLookAngle = 90.0
var lookSensitivity = 0.1

#vectors
var velocity = Vector3()
var mouseDelta = Vector2()

onready var head = $Head
onready var flashlight = $Head/Camera/flashlight/SpotLight
onready var lightRay = $Head/Camera/flashlight/RayCast
var isLightOff = false
var canEnemyRespawn = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	velocity.x = 0
	velocity.z = 0
	
	var input = Vector2()
	
	if Input.is_action_pressed("mov_forward"):
		input.y -= 1
	if Input.is_action_pressed("mov_backwards"):
		input.y += 1
	if Input.is_action_pressed("mov_left"):
		input.x -= 1
	if Input.is_action_pressed("mov_right"):
		input.x += 1
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
		
	input = input.normalized()
	
	var forward = global_transform.basis.z
	var right = global_transform.basis.x
	
	var relativeDir = (forward * input.y + right * input.x)
	
	velocity.x = relativeDir.x * movSpeed
	velocity.z = relativeDir.z * movSpeed
	
	#gravity
	velocity.y -= gravity * delta
	
	#movement
	velocity = move_and_slide(velocity, Vector3.UP)
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * lookSensitivity))
		head.rotate_x(deg2rad(-event.relative.y * lookSensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))
		
	if event.is_action_pressed("act_lightOff"):
		if isLightOff:
			flashlight.light_energy = 1.0
			isLightOff = false
		else:
			flashlight.light_energy = 0.0
			isLightOff = true
			canEnemyRespawn = true

