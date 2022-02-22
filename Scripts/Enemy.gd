extends Spatial
class_name Enemy

var player: Spatial
var gridMap: GridMap

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
var timeLimit = 2

func _process(delta):
	time += delta
	if time > timeLimit:
		time = 0
		changeLocation()

func changeLocation():
	var playerPos = player.global_transform.origin

	var playerPosGrid = gridMap.world_to_map(playerPos)
	playerPosGrid.y = 0
	
	print(checkNeighbors(playerPosGrid))
	
func checkNeighbors(playerPosGrid):
	var list = []
	for i in dirVectors.keys():
		var newDir = playerPosGrid + dirVectors[i]
		if gridMap.get_cell_item(newDir.x, newDir.y, newDir.z) == 0:
			list.append(i)
			
	return list
