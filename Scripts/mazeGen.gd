extends Spatial

const N = 1
const E = 2
const S = 4
const W = 8

var cell_walls = {
	Vector3(0,0,-1) : N,
	Vector3(1,0,0) : E,
	Vector3(0,0,1) : S,
	Vector3(-1,0,0) : W,
}

var tile_size = 2
var width = 15
var height = 15

onready var Map = $GridMap

func _ready():
	randomize()
	tile_size = Map.cell_size
	make_maze()


func check_neighbors(cell, unvisited):
	var list = []
	for n in cell_walls.keys():
		if cell + n in unvisited:
			list.append(cell+n)
	return list
	
func make_maze():
	var unvisited = []
	var stack = []
	
	Map.clear()
	for x in range(width):
		for z in range(height):
			unvisited.append(Vector3(x,0,z))
			Map.set_cell_item(x,0,z, N|E|S|W)
	var current = Vector3(0,0,0)
	unvisited.erase(current)
	while unvisited:
		var neightbors = check_neighbors(current, unvisited)
		if neightbors.size() > 0:
			var next = neightbors[randi() % neightbors.size()]
			stack.append(current)
			var dir = next-current
			var current_walls = Map.get_cell_item(current.x,current.y,current.z) - cell_walls[dir]
			var next_walls = Map.get_cell_item(next.x, next.y, next.z) - cell_walls[-dir]
			Map.set_cell_item(current.x,current.y, current.z, current_walls)
			Map.set_cell_item(next.x, next.y, next.z, next_walls)
			current = next
			unvisited.erase(current)
		elif stack:
			current = stack.pop_back()
