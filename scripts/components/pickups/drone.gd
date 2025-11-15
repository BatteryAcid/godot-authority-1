extends PickupFullAuthComponent

@export var lifetime_seconds: int = 3
@export var input_controller: Node

@onready var _drone_synchronizer: MultiplayerSynchronizer = $DroneSynchronizer
@onready var _hitbox_component: HitboxComponent = $HitboxComponent

func _ready() -> void:
	super._ready()
	_hitbox_component.hit_hurtbox.connect(_hit_hurtbox)
	#print("(Drone) Ready: %s On-peer: %s" % [is_multiplayer_authority(), multiplayer.get_unique_id()])

func _physics_process(delta: float) -> void:
	if get_tree().get_multiplayer().has_multiplayer_peer() and is_multiplayer_authority() \
		and not MatchManager.game_paused and player_tagged.is_player_tagged():
		
		var input_dir = input_controller.input_dir
		var velocity: Vector2 = Vector2(input_dir.x, input_dir.y) * 900
		translate(velocity * delta)
		
		# TODO: for cheat checks, we'd have to manually check if we're on the host-authority
		# peer == "1", last postion and time update greater than X and Y, return to previous position.
		# Get's complicated real quick...

# When Drone hit, remove it.
func _hit_hurtbox(_hurtbox: HurtboxComponent) -> void:
	# print("(Drone) hit_hurtbox %s" % multiplayer.get_unique_id())
	pickup_sprite.animation = "explode"

	set_physics_process(false)
	
	# Here, authority means the peer that owns the item
	if is_multiplayer_authority() and not pickup_sprite.animation_finished.has_connections():
		# print("Auth: %s On-peer: %s" % [is_multiplayer_authority(), multiplayer.get_unique_id()])
		_drone_synchronizer.set_visibility_public(false)
		pickup_sprite.animation_finished.connect(clean_up)

# TODO: can all this be moved to its own script/component? We can have a parent script like "LifetimeManager" with impls
# that manage the specific scenarios: 1. for input only cleanup, 2. for whole item authority
# Assume this will always be called from the same authority that owns the MultiplayerSpawner for this item.
# So the host-authority peer.
func set_lifetime(_seconds: int):
	print("(Drone) Item will last %s seconds!" % lifetime_seconds)
	get_tree().create_timer(lifetime_seconds).timeout.connect(clean_up)

# On host authority
func clean_up():
	# From the auth-host, send rpc to current owner of item, to stop data sync.
	if player_tagged.is_player_tagged():
		_kill_sync.rpc_id(str(player_tagged.tagged_player_name).to_int())
	else:
		# If no player is tagged, just despawn, no visibility changes needed.
		_despawn()

# Need any_peer as a non-host can also be authority. This sends a message to the
# peer that has authority over the whole item.
@rpc("any_peer", "call_local", "reliable")
func _kill_sync():
	print("(Drone) Killing visibility on peer: %s" % multiplayer.get_unique_id())
	# On peer that owns item, cancel synching data
	_drone_synchronizer.set_visibility_public(false)
	# Once sync is killed, tell the auth-host to despawn item
	_despawn.rpc_id(1)

# Must use any_peer as any peer can have authority of this item.
@rpc("any_peer", "call_local", "reliable")
func _despawn():
	print("(Drone) Despawn on peer: %s" % multiplayer.get_unique_id())
	# We must check that we are on peer 1, host-authority, as that holds authority
	# over the MultiplayerSpawner responsible for spawning this item. 
	if get_tree().get_multiplayer().get_unique_id() == 1:
		queue_free()
		
		
		
		
