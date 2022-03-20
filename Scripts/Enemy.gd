extends Spatial

var player: KinematicBody
var gridMap: GridMap
var freeTiles: Array

enum dir {
	N,
	E,
	S,
	W
}

var dirVectors = {
	N = Vector3(0,0,-1),
	E = Vector3(1,0,0),
	S = Vector3(0,0,1),
	W = Vector3(-1,0,0)
}

var locTime = 0
var locTimeLimit = 10

var aggroTime = 0
var aggroTimeLimit = 15

var detection = {
	playerSeen = false,
	playerSensed = false
}

var aggression = 1

onready var ray = $RayCast as RayCast
onready var area = $Area as Area
onready var detectionLabel = get_node('../HUDCanvas/HUDControl/DetectionLabel') as Label
onready var aggressionValueLabel = get_node('../HUDCanvas/HUDControl/AggressionLabel/AggresionValue') as Label

func _ready():
	detectionLabel.text = 'player not sensed or seen'

func _physics_process(delta):
	aggressionValueLabel.text = aggressionToText()
	
	print(locTime)
	if (!detection.playerSensed and !detection.playerSeen):
		locTime += delta
	
	if (locTime > locTimeLimit):
		locTime = 0
		changeLocation()
	
	look_at(player.transform.origin, Vector3(0,1,0))

	if detection.playerSensed and ray.is_colliding() and ray.get_collider() is Player and !player.isLightOff:
		detection.playerSeen = true
		detectionLabel.text = 'player seen and sensed'
		aggression += 2
	elif ray.is_colliding() and ray.get_collider() is Player and !player.isLightOff:
		detection.playerSeen = true
		detectionLabel.text = 'player seen'
		aggression += 1
	elif (detection.playerSensed and player.isLightOff) or detection.playerSensed:
		detection.playerSeen = false
		detectionLabel.text = 'player sensed'
	else:
		detection.playerSeen = false
		detectionLabel.text = 'player not sensed or seen'
		if aggression > 1:
			aggression -= 1

func changeLocation():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var playerPos = player.global_transform.origin
	var playerPosGrid = gridMap.world_to_map(playerPos)
	playerPosGrid.y = 0
	
	var newLoc = gridMap.map_to_world(freeTiles[rng.randi_range(0,freeTiles.size()-1)].x,freeTiles[rng.randi_range(0,freeTiles.size()-1)].y,freeTiles[rng.randi_range(0,freeTiles.size()-1)].z)
	
	transform.origin = newLoc

func aggressionToText():
	if aggression <= 100:
		return 'Target is docile'
	if aggression <= 200:
		return 'Minimal aggression'
	if aggression <= 300:
		return 'Target is aggresive'
	if aggression <= 400:
		return 'Take evasive action!'
	if aggression <= 500:
		return 'LEAVE IMMEDIATELY!'
	if aggression > 500:
		return 'you are dead'

func _on_Area_body_entered(body):
	if body is Player:
		detection.playerSensed = true

func _on_Area_body_exited(body):
	detection.playerSensed = false
