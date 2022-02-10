extends KinematicBody

var curHP = 10
var maxHP = 10
var score = 0

#physics
var movSpeed = 2.0
var gravity = 12.0

#camera
var minLookAngle = -90.0
var maxLookAngle = 90.0
var lookSensitivity = 25.0

#vectors
var velocity = Vector3()
var mouseDelta = Vector2()

onready var camera = $Camera
onready var flashlight = $Camera/flashlight/SpotLight
var isLightOff = false

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

func _process(delta):
	camera.rotation_degrees.x -= mouseDelta.y * lookSensitivity * delta
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, minLookAngle, maxLookAngle)
	
	rotation_degrees.y -= mouseDelta.x * lookSensitivity * delta
	
	mouseDelta = Vector2()
	
func _input(event):
	if event is InputEventMouseMotion:
		mouseDelta = event.relative
		
	if event.is_action_pressed("act_lightOff"):
		if isLightOff:
			flashlight.light_energy = 1.0
			isLightOff = false
		else:
			flashlight.light_energy = 0.0
			isLightOff = true

