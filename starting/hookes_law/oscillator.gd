extends Node2D

var force          = Vector2( 0.0  , 0.0 )
var node_mass      = 1.00
var infinitesimal  = Transform2D( 0.05, Vector2( 0.0, 0.0 ) )

# mouse drag params 
var selectionDistance = 50
var pressed           = false
var selection         = null

# bodies
var bodies         = [ ]
var links          = [ ]
var link_object    = load("res://spring.tscn")

# are the keys "→", "←", "↑" or "↓" pressed
var MOVE_LFT = false
var MOVE_RGT = false
var MOVE_UP  = false
var MOVE_DWN = false
var inf_DU   = Vector2(0.0,20.0)
var inf_RL   = Vector2(20.0,0.0)

func _ready():
	for node in get_children():
		bodies.push_back(node)

	for i in range( bodies.size() ):
		bodies[i].set_velocity( Vector2() )
		bodies[i].set_mass( node_mass )
		for j in range(bodies.size()):
			if bodies[i] != bodies[j]:
				bodies[i].neighbors.append(bodies[j])
				bodies[i].stiffness.append(10)
				bodies[i].resting_length.append(100)
		for j in range(i):
			# TODO: link creation
			create_spring(bodies[i],bodies[j])


func create_spring(node_1, node_2):
	var link = link_object.instance()
	link.initialize( node_1, node_2 )
	$"../springs".add_child( link )

func _input(event):
	if event.is_action_pressed("ui_left"):
		MOVE_LFT = true
	if event.is_action_released("ui_left"):
		MOVE_LFT = false
	if event.is_action_pressed("ui_right"):
		MOVE_RGT = true
	if event.is_action_released("ui_right"):
		MOVE_RGT = false
	if event.is_action_pressed("ui_up"):
		MOVE_UP  = true
	if event.is_action_released("ui_up"):
		MOVE_UP  = false
	if event.is_action_pressed("ui_down"):
		MOVE_DWN = true
	if event.is_action_released("ui_down"):
		MOVE_DWN = false
		
	# mouse drag
	if event is InputEventMouseMotion:
		if pressed:
			if selection != null:
				selection.position          = event.position
				selection.previous_position = event.position
		else:
			selection = null
			for node in get_children():
				if event.position.distance_to(node.position) < selectionDistance:
					selection = node
	if event is InputEventMouseButton:
		if event.pressed:
			pressed   = true
			selection = null
			for node in get_children():
				if event.position.distance_to(node.position) < selectionDistance:
					selection = node
		else:
			pressed   = false
			selection = null

func _process(delta):
	if MOVE_LFT:
		bodies[0].position -= inf_RL*delta
	if MOVE_RGT:
		bodies[0].position += inf_RL*delta
	if MOVE_UP:
		bodies[0].position -= inf_DU*delta
	if MOVE_DWN:
		bodies[0].position += inf_DU*delta
	update()

func draw_arrow( from, to, color = Color(1.0, 1.0, 1.0, 0.5) ):
	var arrow_point = PoolVector2Array()
	var color_point = PoolColorArray()
	var vec = to - from
	if vec.length() > 10.0:
		arrow_point.append(to + 5.0  * vec.normalized().tangent())
		color_point.append(color)
		arrow_point.append(to - 5.0  * vec.normalized().tangent())
		color_point.append(color)
		arrow_point.append(to + 10.0 * vec.normalized())
		color_point.append(color)
		draw_line ( from, to, color, 3 )
		draw_polygon(arrow_point,color_point)

func draw_spring(from, to):
	pass

func _draw():
	for body in bodies:
		draw_arrow(body.position, body.position + body.velocity)
		
	if selection != null:  # draw selected point
		draw_circle( selection.position, 30, Color( 1, 1, 1, 0.3 ) )