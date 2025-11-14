extends PickupAuthComponent

# When the "Side kick" is claimed, use arrow keys to hit the other player.
# Demonstrates "authority swapping" of the InputController. Inputs are then 
# applied to the object on the host-authority peer, then position is synched 
# back to the peers. This is similar to how we are currently handling player's
# movement.
#
# NOTE: I think it's important to point out the added complexity in swapping
# authority of an item, that is short lived. In order to be mostly sure we don't
# get "Node not found" or sync errors, we have to do this "back and forth" RPC
# to turn off synching on the item-owned-peer and the auth-host. Timeouts can 
# also be leveraged, but latency between peers could still cause this to occur.
# This would also need a failsafe queue_free just in case the RPC dance fails.

@onready var _hitbox_component: HitboxComponent = $HitboxComponent
@onready var side_kick_input_synchronizer: MultiplayerSynchronizer = $SideKickInputController/SideKickInputSynchronizer

var spent = false # Indicates whether or not the item has been used.

func _ready() -> void:
	super._ready()
	_hitbox_component.hit_hurtbox.connect(_hit_hurtbox)

func _physics_process(delta: float) -> void:
	if get_tree().get_multiplayer().has_multiplayer_peer() and is_multiplayer_authority() \
		and not MatchManager.game_paused and not player_tagged.tagged_player_name == "" and not spent:
		
		var input_dir = input_controller.input_dir
		var velocity: Vector2 = Vector2(input_dir.x, input_dir.y) * 900
		translate(velocity * delta)

# When mine hit, remove it.
func _hit_hurtbox(_hurtbox: HurtboxComponent) -> void:
	#print("Side kick _hit_hurtbox entered") # TODO: remove
	if spent: return # Prevents multiple "hits"
	#print("Side kick registered hit") # TODO: remove
	spent = true
	pickup_sprite.animation = "explode"
	
	# This is an attempt to prevent "Node not found" errors that happen after
	# the Side Kick is queue_free.
	side_kick_input_synchronizer.set_visibility_public(false) 

	if is_multiplayer_authority() and not pickup_sprite.animation_finished.has_connections():
		# print("Auth: %s On-peer: %s" % [is_multiplayer_authority(), multiplayer.get_unique_id()])
		pickup_sprite.animation_finished.connect(queue_free)

func set_lifetime(seconds: int):
	print("(Side Kick) Item will last %s seconds!" % seconds)
	# Auth-host after timeout -> Auth-host kill-sync RPC-> local-peer-input-auth -> local-peer-auth kill visibility RPC-> host-auth queue_free
	# This works but still needs a fallback incase this back and forth fails. A failsafe timeout
	get_tree().create_timer(seconds).timeout.connect(kill_sync)

func kill_sync():
	# From the auth-host, send rpc to current owner of item, to stop data sync.
	_kill_sync.rpc_id(str(player_tagged.tagged_player_name).to_int())

@rpc("authority", "call_remote", "reliable")
func _kill_sync():
	# On peer that owns item, cancel synching data
	side_kick_input_synchronizer.set_visibility_public(false)
	# Tell the auth-host to despawn item
	_despawn.rpc_id(1)

@rpc("any_peer", "call_local", "reliable")
func _despawn():
	#side_kick_input_synchronizer.set_visibility_public(false) 
	if is_multiplayer_authority():
		queue_free()
		
		# IMPORTANT: This is not an exact fix to the "Node not found" error.
		# Turning off the synchronizer's visibility, along with a pause between
		# a queue_free call, is a way to reduce the chance of the error, not 
		# completely prevent it.
		# Another option, is to set Replicate setting to on_change, which reduces
		# network traffic that may trigger this error.
		#side_kick_input_synchronizer.set_visibility_public(false) 
		#await get_tree().create_timer(1).timeout
		#queue_free()

# NOTE: Overridden to handle the case where it's picked up but not used,
# the timeout to queue_free still must be preceded by setting visibility to false.
# Reduces chance of "Node not found" error, read comments in _despawn below.
# Only called from authority upon spawn.
#func set_lifetime(seconds: int):
	#print("(Side Kick) Item will last %s seconds!" % seconds)
	#get_tree().create_timer(seconds).timeout.connect(_despawn)


# TODO: may need this when we give full control over object
#func _call_despawn():
	## Call directly to the server peer, as they have ownership over the spawner.
	#_despawn.rpc_id(1)
#
#@rpc("any_peer", "call_local")
#func _despawn():
	#if not is_multiplayer_authority(): return
	##side_kick_input_synchronizer.set_visibility_public(false) 
	##side_kick_input_synchronizer.set_visibility_for(0, true)
	#print("Despawn")
	#queue_free()
