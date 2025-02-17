extends Control

@export var separation_px = 8

var children : Array[Node] = []
var children_positions : Array[int] = []
var total_height: int = 0
	
func calculate_child_positions():
	children = get_children()
	children_positions = []
	
	total_height = 0
	for i in children.size():
		var center = int(children[i].size.y / 2)
		children_positions.append(center + total_height)
		total_height += children[i].size.y + separation_px
		#children_positions.append()
	
	total_height -= separation_px
	#print("Total height: " + str(total_height))
	#print("Children positions: " + str(children_positions))
	
	move_children()

func move_children():
	for i in children.size():
		var new_pos_y = children_positions[i] - int(children[i].size.y / 2) - int(total_height / 2)
		var new_pos_x = 0 - int(children[i].size.x / 2)
		children[i].move_to_slot("position", Vector2(new_pos_x, new_pos_y))
		#test
