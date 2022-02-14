extends Navigation

onready var agent = get_node("Spatial") as Spatial
onready var player = get_node("../Player") as KinematicBody

var timer = 0
var timer_limit = 1
var path = []

var begin = Vector3()
var end = Vector3()

const SPEED = 4.0

func _ready():
	var path_begin = get_closest_point(agent.global_transform.origin)
	
	# And we want to arrive at the player's position
	var player_pos = player.global_transform.origin
	var path_end = get_closest_point(player_pos)
	
	# Get a simple path, convert it into an array (for easier access) and invert the path
	var p = get_simple_path(path_begin, path_end)
	path = Array(p)
	
func _process(delta):
	if path.size() > 1:
		var to_walk = delta * SPEED
		var to_watch = Vector3(0, 1, 0)
		while to_walk > 0 and path.size() >= 2:
			var pfrom = path[path.size() - 1]
			var pto = path[path.size() - 2]
			to_watch = (pto - pfrom).normalized()
			var d = pfrom.distance_to(pto)
			if d <= to_walk:
				path.remove(path.size() - 1)
				to_walk -= d
			else:
				path[path.size() - 1] = pfrom.linear_interpolate(pto, to_walk/d)
				to_walk = 0
		
		var atpos = path[path.size() - 1]
		var atdir = to_watch
		atdir.y = 0
		
		var t = Transform()
		t.origin = atpos
		t = t.looking_at(atpos + atdir, Vector3(0, 1, 0))
		agent.set_transform(t)
		
		if path.size() < 2:
			path = []
			set_process(false)
	else:
		set_process(false)
		
func _physics_process(delta):
	timer += delta
	if (timer > timer_limit):
		timer -= timer_limit
		_update_path()

func _update_path():
	begin = get_closest_point(agent.get_translation())
	end = get_closest_point(player.get_translation())
	
	var p = get_simple_path(begin, end, true)
	path = Array(p) # Vector3array too complex to use, convert to regular array
	path.invert()
	set_process(true)
