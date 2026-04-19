extends CharacterBody2D
class_name EnemyBase

@export var max_fear_bar: int # Enemy's HP
@export var speed: float
@export var terror_energy: int # Enemy Drop

# Some runtime variables
var current_fear_bar: int 

func _ready() -> void:
	current_fear_bar = max_fear_bar
