extends PickupComponent
# TODO: maybe rename to something that describes the action better...
# - maybe call this a mine, like whoever "arms" it, gets control, and it will hurt the other player.

# When the action-key is pressed, demonstrate how to use an RPC to execute action.

@onready var _hitbox_component: HitboxComponent = $HitboxComponent

func _ready() -> void:
	super._ready()
	_hitbox_component.hit_hurtbox.connect(_hit_hurtbox)

func _picked_up(collector: Area2D):
	super._picked_up(collector)

# When mine hit, remove it.
func _hit_hurtbox(hurtbox: HurtboxComponent) -> void:
	# TODO: show animation
	pickup_sprite.animation = "explode"
	
	if is_multiplayer_authority() and not pickup_sprite.animation_finished.has_connections():
		pickup_sprite.animation_finished.connect(queue_free)



# Save the "on action" stuff for the next level example...
#func _physics_process(_delta: float) -> void:
	#if get_tree().get_multiplayer().has_multiplayer_peer() and is_multiplayer_authority() and not MatchManager.game_paused:
		#if Input.is_action_just_pressed("action_1"):
			#attack.rpc()
#
#@rpc("any_peer", "call_local")
#func attack():
	#print("attack")
