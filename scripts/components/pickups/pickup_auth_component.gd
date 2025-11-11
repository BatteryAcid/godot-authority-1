class_name PickupAuthComponent
extends PickupComponent

@export var input_controller: Node

# Make sure this is only called on authority, this is where we'll process the collision detection
func _picked_up(collector: Area2D):	
	if not is_multiplayer_authority() or not collector is CollectorComponent: return
	
	if player_tagged.tagged_player_name == "":
		print("(Auth) Item picked up by %s!" % collector.get_parent().name)
		player_tagged.tagged_player_name = collector.get_parent().name
		inform_peers_control_taken.rpc(player_tagged.tagged_player_name) # Use RPC to sync the player that is tagged with picking up the item

# Call this from authority to inform peers of object ownership
@rpc("authority", "call_local")
func inform_peers_control_taken(new_player_tagged: String):
	print("(Auth) Control taken by %s" % new_player_tagged)
	# If you wanted the item to hit any player, leave this null, would have to move to overridden function
	player_tagged.tagged_player_name = new_player_tagged
	pickup_sprite.animation = "armed"
	
	# NOTE: Authority must be set on all peers. 
	input_controller.set_multiplayer_authority(str(new_player_tagged).to_int(), true)
