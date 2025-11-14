class_name PickupAuthComponent
extends PickupComponent

# TODO: rename this to PickupInputAuthComponent - this designates we only give authority over the inputs
# - will need another example where we give FULL authority (PickupFullAuthComponent)over the object. Not sure that's possible
# given that it was spawned by the authority...

@export var input_controller: Node

# Called from the superclass, overridden here to set authority over the object's
# input controller, so the assigned peer can control it's movement.
@rpc("authority", "call_local")
func inform_peers_control_taken(new_player_tagged: String):
	print("(Auth) Control taken by %s" % new_player_tagged)
	# If you wanted the item to hit any player, leave this null, would have to move to overridden function
	player_tagged.tagged_player_name = new_player_tagged
	pickup_sprite.animation = "armed"
	
	# NOTE: Authority must be set on all peers. 
	input_controller.set_multiplayer_authority(str(new_player_tagged).to_int(), true)
