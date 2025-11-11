extends PickupComponent

# When the action-key is pressed, demonstrate how to use an RPC to execute action.

@onready var _hitbox_component: HitboxComponent = $HitboxComponent

func _ready() -> void:
	super._ready()
	_hitbox_component.hit_hurtbox.connect(_hit_hurtbox)

#func _picked_up(collector: Area2D):
	#super._picked_up(collector)

# When mine hit, remove it.
func _hit_hurtbox(_hurtbox: HurtboxComponent) -> void:
	pickup_sprite.animation = "explode"
	
	if is_multiplayer_authority() and not pickup_sprite.animation_finished.has_connections():
		pickup_sprite.animation_finished.connect(queue_free)



# Save the "on action" stuff for the next level example...
#func _physics_process(_delta: float) -> void:
	#print("attack")
	
	#if get_tree().get_multiplayer().has_multiplayer_peer() and is_multiplayer_authority() and not MatchManager.game_paused:
		#if Input.is_action_just_pressed("action_3"):
			#print("attack")
			#attack.rpc()
#
#@rpc("any_peer", "call_local")
#func attack():
	#print("attack")
