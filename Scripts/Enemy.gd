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

var time = 0
var timeLimit = 30
var flash = 0
var flashLimit = 10
var canChangeLocation = true
onready var ray = $RayCast as RayCast
onready var area = $Area as Area

func _physics_process(delta):
	look_at(player.transform.origin, Vector3(0,1,0))
	if ray.is_colliding() and ray.get_collider() is Player and player.canEnemyRespawn and !player.isLightOff:
		if !(flash >= flashLimit):
			changeLocation()
			player.canEnemyRespawn = false
			flash += 1

func _process(delta):
	time += delta
	if time > timeLimit:
		time = 0
		changeLocationFree()

func changeLocation():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var playerPos = player.global_transform.origin
	var playerPosGrid = gridMap.world_to_map(playerPos)
	playerPosGrid.y = 0
	
	var freeCells = checkNeighbors(playerPosGrid)
	if(rng.randi_range(0,freeCells.size()-1) != -1):
		transform.origin = gridMap.map_to_world(freeCells[rng.randi_range(0,freeCells.size()-1)].x,freeCells[rng.randi_range(0,freeCells.size()-1)].y,freeCells[rng.randi_range(0,freeCells.size()-1)].z)
	
func changeLocationFree():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	if(rng.randi_range(0,freeTiles.size()-1) != -1):
		transform.origin = gridMap.map_to_world(freeTiles[rng.randi_range(0,freeTiles.size()-1)].x,freeTiles[rng.randi_range(0,freeTiles.size()-1)].y,freeTiles[rng.randi_range(0,freeTiles.size()-1)].z)

func checkNeighbors(playerPosGrid):
	var list = []
	for i in dirVectors.keys():
		var newDir = playerPosGrid + dirVectors[i]
		if gridMap.get_cell_item(newDir.x, newDir.y, newDir.z) == 0:
			list.append(newDir)
			
	return list
