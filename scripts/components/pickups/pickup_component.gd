class_name PickupComponent
extends Area2D

@export var sprite: AnimatedSprite2D
var controlled_by: Variant = null # TODO: can be better handled by composition, variant was just to get it working

func _ready() -> void:
	area_entered.connect(_picked_up)
	
# TODO: this may be better done through composition
func _picked_up(controller):
	print("Item picked up! Override with custom functionality!")
	if controlled_by != null:
		controlled_by = controller
