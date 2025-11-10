extends Node

@onready var pickup_spawn_path: Node2D = get_tree().current_scene.get_node("%Pickups")
var pickup_item_scene: PackedScene = load("res://scenes/pickups/big_gun.tscn") 
# TODO: refactor to handle more than one...
# TODO: convert to list of items

var _pickup_item: PickupComponent = null

func _ready() -> void:
	var spawner: MultiplayerSpawner = get_child(0)
	spawner.spawn_path = pickup_spawn_path.get_path()

# TODO: add keybind support for the different scenarios, probably move towards numbers
func _physics_process(_delta: float) -> void:
	if get_tree().get_multiplayer().has_multiplayer_peer() and is_multiplayer_authority() and not MatchManager.game_paused:
		if Input.is_action_just_pressed("1") and _pickup_item == null:
			_spawn_pickup_item()

func _spawn_pickup_item():
	var pickup_to_add = pickup_item_scene.instantiate()
	pickup_to_add.set_multiplayer_authority(1)
	pickup_to_add.global_transform = Transform2D(0, Vector2(randi_range(500, 1300), randi_range(200, 800)))
	
	pickup_spawn_path.add_child(pickup_to_add, true)
	_pickup_item = pickup_to_add
	
	# RPC to synch spawn location on spawn, so we don't have to use a synchronizer
	_pickup_item.set_pickup_transform.rpc(pickup_to_add.global_transform)
	
	# kill after some time
	# TODO: could move to store this in the item itself
	_pickup_item.set_lifetime(10)
