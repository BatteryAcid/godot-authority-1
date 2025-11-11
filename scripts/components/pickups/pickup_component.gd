class_name PickupComponent
extends Area2D

# LIMITATIONS:
# - for demo purposes, we'll only sync positions upon spawn, meaning late joining peers won't have
# the object's location properly synched.

@export var player_tagged: PlayerTagged
@export var pickup_sprite: AnimatedSprite2D
var pickup_animation = "default"

func _ready() -> void:
	if is_multiplayer_authority():
		area_entered.connect(_picked_up)
	
# TODO: this may be better done through composition
# Make sure this is only called on authority, this is where we'll process the collision detection
func _picked_up(collector: Area2D):
	if not is_multiplayer_authority() or not collector is CollectorComponent: return
	
	if player_tagged.tagged_player_name == "":
		print("Item picked up by %s!" % collector.get_parent().name)
		player_tagged.tagged_player_name = collector.get_parent().name
		inform_peers_control_taken.rpc(player_tagged.tagged_player_name) # Use RPC to sync the player that is tagged with picking up the item

# Call this from authority to inform peers of object ownership
@rpc("authority", "call_local")
func inform_peers_control_taken(new_player_tagged: String):
	print("Control taken by %s" % new_player_tagged)
	# If you wanted the item to hit any player, leave this null, would have to move to overridden function
	player_tagged.tagged_player_name = new_player_tagged
	pickup_sprite.animation = "armed"
	
@rpc("authority")
func set_pickup_transform(pickup_transform: Transform2D):
	global_transform = pickup_transform

# NOTE: the way this currently works, it is killed regardless of whether or not it's controlled
func set_lifetime(seconds: int):
	print("Item will last %s seconds!" % seconds)
	get_tree().create_timer(seconds).timeout.connect(queue_free)
