class_name PickupFullAuthComponent
extends PickupComponent

# Use this component on items that assign full authority to a peer.

# Called from the superclass, overridden to set full authority over the item.
@rpc("authority", "call_local")
func inform_peers_control_taken(new_player_tagged: String):
	# print("(Full-Auth) Control taken by %s" % new_player_tagged)
	super(new_player_tagged)
	
	# NOTE: Authority must be set on all peers. 
	# Given FULL authority over entire object
	set_multiplayer_authority(str(new_player_tagged).to_int(), true)
