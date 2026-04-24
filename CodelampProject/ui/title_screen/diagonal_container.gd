@tool

extends Container
class_name DiagonalContainer

@export var x_dev: float = 10.0:
	set(value):
		x_dev = value
		queue_sort() #Force Editor to fixed layout
		
@export var y_dev: float = 10.0:
	set(value):
		y_dev = value
		queue_sort()

@export var rot_dev: float = 10.0:
	set(value):
		rot_dev = value
		queue_sort()

func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		var children = get_children()
		var count: int = children.size()
		for i in count:
			var c = children[i] as Control
			var index: int = (count - 1) - i
			c.pivot_offset = Vector2(c.size.x, c.size.y)
			c.position = Vector2(-index * x_dev - c.size.x, -index * y_dev)
			c.rotation_degrees = index * rot_dev
