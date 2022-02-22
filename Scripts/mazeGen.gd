extends Spatial

const DIR = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]

var tile_size = 2
var size = 25
var steps = 300

var player
var enemy
var playerSpawned: bool = false
var enemySpawned: bool = false
var playerScene = load("res://Scenes/Player.tscn")
var enemyScene = load("res://Scenes/Enemy.tscn")

onready var Nav = $Navigation
onready var Map = $Navigation/NavigationMeshInstance/GridMap as GridMap

func _ready():
	randomize()
	make_maze()
	
func spawnPlayer(current_pos):
	player = playerScene.instance() as Spatial
	player.transform.origin = Map.map_to_world(current_pos.x, 0, current_pos.y)
	add_child(player)
	playerSpawned = true
		
func spawnEnemy(current_pos):
	enemy = enemyScene.instance() as Position3D
	enemy.transform.origin = Map.map_to_world(current_pos.x, 0, current_pos.y)
	Nav.add_child(enemy)
	enemySpawned = true
	
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
			Map.set_cell_item(x,0,z,1)
	
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
		Map.set_cell_item(current_pos.x, 0, current_pos.y, 0)
		if(!playerSpawned):
			spawnPlayer(current_pos)
	spawnEnemy(current_pos)

