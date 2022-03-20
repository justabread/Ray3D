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
var locTimeLimit = 20

var changeTime = 0
var changeTimeLimit = 5

var detection = {
	playerSeen = false,
	playerSensed = false
}

var aggression = 1

var canChangeLoc = true
onready var ray = $RayCast as RayCast
onready var area = $Area as Area
onready var detectionLabel = get_node('../HUDCanvas/HUDControl/DetectionLabel') as Label
onready var aggressionValueLabel = get_node('../HUDCanvas/HUDControl/AggressionLabel/AggresionValue') as Label

func _ready():
	detectionLabel.text = 'player not sensed or seen'

func _physics_process(delta):
	aggressionValueLabel.text = String(aggression)
	print(delta)
	
	locTime += delta
	changeTime += delta
	
	if locTime > locTimeLimit:
		locTime = 0
		changeLocationFree()
	
	if (changeTime > changeTimeLimit) and (canChangeLoc == false):
		changeTime = 0
		canChangeLoc = true
	
	look_at(player.transform.origin, Vector3(0,1,0))

	if detection.playerSensed and ray.is_colliding() and ray.get_collider() is Player and !player.isLightOff:
		detection.playerSeen = true
		detectionLabel.text = 'player seen and sensed'
		if canChangeLoc:
			changeLocation()
			aggression += 1
			canChangeLoc = false
	elif ray.is_colliding() and ray.get_collider() is Player and !player.isLightOff:
		detection.playerSeen = true
		detectionLabel.text = 'player seen'
		if canChangeLoc:
			aggression += 1
			canChangeLoc = false
	elif (detection.playerSensed and player.isLightOff) or detection.playerSensed:
		detection.playerSeen = false
		detectionLabel.text = 'player sensed'
	else:
		detection.playerSeen = false
		detectionLabel.text = 'player not sensed or seen'

func changeLocation():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var playerPos = player.global_transform.origin
	var playerPosGrid = gridMap.world_to_map(playerPos)
	playerPosGrid.y = 0
	
	var freeCells = checkNeighbors(playerPosGrid)
	var newLoc = gridMap.map_to_world(freeCells[rng.randi_range(0,freeCells.size()-1)].x,freeCells[rng.randi_range(0,freeCells.size()-1)].y,freeCells[rng.randi_range(0,freeCells.size()-1)].z)
	
	while(newLoc == playerPos):
		newLoc = gridMap.map_to_world(freeCells[rng.randi_range(0,freeCells.size()-1)].x,freeCells[rng.randi_range(0,freeCells.size()-1)].y,freeCells[rng.randi_range(0,freeCells.size()-1)].z)
	
	if(rng.randi_range(0,freeCells.size()-1) != -1):
		transform.origin = newLoc
	
func changeLocationFree():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	if(rng.randi_range(0,freeTiles.size()-1) != -1):
		transform.origin = gridMap.map_to_world(freeTiles[rng.randi_range(0,freeTiles.size()-1)].x,freeTiles[rng.randi_range(0,freeTiles.size()-1)].y,freeTiles[rng.randi_range(0,freeTiles.size()-1)].z)

func checkNeighbors(playerPosGrid):
	var list = []
	for i in dirVectors.keys():
		var newDir = playerPosGrid + dirVectors[i]
		if (gridMap.get_cell_item(newDir.x, newDir.y, newDir.z) != 15) or (gridMap.get_cell_item(newDir.x, newDir.y, newDir.z) != -1):
			list.append(newDir)
			
	return list


func _on_Area_body_entered(body):
	if body is Player:
		detection.playerSensed = true

func _on_Area_body_exited(body):
	detection.playerSensed = false
