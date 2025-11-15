class_name PickupInputAuthComponent
extends PickupComponent

# Reuse this component on items where the inputs are controlled by a peer.

@export var input_controller: Node

# Called from the superclass, overridden to set authority over the object's
# input controller, so the assigned peer can control it's movement.
@rpc("authority", "call_local")
func inform_peers_control_taken(new_player_tagged: String):
	# print("(Auth) Control taken by %s" % new_player_tagged)

	super(new_player_tagged)
	
	# NOTE: Authority must be set on all peers. 
	input_controller.set_multiplayer_authority(str(new_player_tagged).to_int(), true)
