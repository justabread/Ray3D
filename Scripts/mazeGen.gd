extends Spatial

const N = 1
const E = 2
const S = 4
const W = 8

const DIR = {
	Vector3(0,0,-1): N,
	Vector3(1,0,0): E,
	Vector3(0,0,1): S,
	Vector3(-1,0,0): W
}

var tile_size = 2
var width = 10
var height = 10

var player
var enemy
var freeTiles = []
var playerSpawned: bool = false
var enemySpawned: bool = false
var playerScene = load("res://Scenes/Player.tscn")
var enemyScene = load("res://Scenes/Enemy.tscn")

onready var Map = $GridMap as GridMap

func _ready():
	randomize()
	make_maze()
	
func spawnPlayer(current_pos):
	player = playerScene.instance() as KinematicBody
	player.transform.origin = Map.map_to_world(current_pos.x, 0, current_pos.y)
	add_child(player)
	playerSpawned = true
	
func spawnEnemy(current_pos):
	enemy = enemyScene.instance() as Spatial
	if(player != null):
		enemy.player = player
		enemy.gridMap = Map
		enemy.freeTiles = freeTiles
	
	enemy.transform.origin = Map.map_to_world(current_pos.x, 0, current_pos.y)
	add_child(enemy)
	enemySpawned = true

func check_neighbors(cell, unvisited):
	var list = []
	for n in DIR.keys():
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
	spawnPlayer(current)
	while unvisited:
		var neighbors = check_neighbors(current, unvisited)
		if neighbors.size() > 0:
			var next = neighbors[randi() % neighbors.size()]
			stack.append(current)
			var dir = next-current
			var current_walls = Map.get_cell_item(current.x,current.y,current.z) - DIR[dir]
			var next_walls = Map.get_cell_item(next.x, next.y, next.z) - DIR[-dir]
			Map.set_cell_item(current.x,current.y, current.z, current_walls)
			Map.set_cell_item(next.x, next.y, next.z, next_walls)
			current = next
			unvisited.erase(current)
			if current_walls != 15:
				freeTiles.append(current)
		elif stack:
			current = stack.pop_back()
	spawnEnemy(current)

