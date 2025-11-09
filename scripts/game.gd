extends Node2D

@export var player_scene: PackedScene

func _ready() -> void:
	if NetworkManager.is_hosting_game:
		var spawn_manager_scene = load("res://scenes/multiplayer/spawn_manager.tscn")
		var spawn_manager = spawn_manager_scene.instantiate()
		spawn_manager.player_scene = player_scene
		add_child(spawn_manager)
		
		# Pickup spawner
		var pickup_spawner_node = Node2D.new() #load("res://scenes/pickup.tscn")
		var pickup_spawner_script = load("res://scripts/components/pickups/pickup_spawner.gd")#pickup_spawner_scene.instantiate()
		pickup_spawner_node.set_script(pickup_spawner_script)
		pickup_spawner_node.name = "PickupSpawner"
		#spawn_manager.player_scene = player_scene
		add_child(pickup_spawner_node)

func _on_main_menu_pressed() -> void:
	NetworkManager.terminate_connection_load_main_menu()
