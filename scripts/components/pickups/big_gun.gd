extends PickupComponent

func _picked_up(controller):
	if controlled_by == null:
		print("Item picked up by %s!" % controller.name)
		controlled_by = controller
