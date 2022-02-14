extends Spatial

const DIR = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]

var tile_size = 2
var size = 25
var steps = 300

var player
var playerSpawned: bool = false
var playerScene = load("res://Scenes/Player.tscn")

onready var Map = $Navigation/NavigationMeshInstance/GridMap as GridMap

func _ready():
	randomize()
	make_maze()
	
func make_maze():
#	var unvisited = []
#	var stack = []
#
#	Map.clear()
#	for x in range(width):
#		for z in range(height):
#			unvisited.append(Vector3(x,0,z))
#			Map.set_cell_item(x,0,z, N|E|S|W)
#	var current = Vector3(0,0,0)
#	unvisited.erase(current)
#	while unvisited:
#		var neighbors = check_neighbors(current, unvisited)
#		if neighbors.size() > 0:
#			var next = neighbors[randi() % neighbors.size()]
#			stack.append(current)
#			var dir = next-current
#			var current_walls = Map.get_cell_item(current.x,current.y,current.z) - cell_walls[dir]
#			var next_walls = Map.get_cell_item(next.x, next.y, next.z) - cell_walls[-dir]
#			Map.set_cell_item(current.x,current.y, current.z, current_walls)
#			Map.set_cell_item(next.x, next.y, next.z, next_walls)
#			current = next
#			unvisited.erase(current)
#		elif stack:
#			current = stack.pop_back()

	#Fill map with cubes
	for x in range(size+1):
		for z in range(size+1):
			Map.set_cell_item(x,0,z,0)
	
	var current_pos = Vector2(size / 2,size / 2)
	var current_dir = Vector2.RIGHT
	
	for i in range(0, steps):
		var temp_dir = DIR.duplicate()
		temp_dir.shuffle()
		var d = temp_dir.pop_front()
		
		while(abs(current_pos.x + d.x) >= size or abs(current_pos.y + d.y) >= size or (current_pos.x + d.x) < 1 or (current_pos.y + d.y) < 1):
			temp_dir.shuffle()
			d = temp_dir.pop_front()
		current_pos += d
		Map.set_cell_item(current_pos.x, 0, current_pos.y, 1)
		if(!playerSpawned):
			player = playerScene.instance() as Spatial
			player.transform.origin = Map.map_to_world(current_pos.x, 0, current_pos.y)
			add_child(player)
			playerSpawned = true
