extends PickupAuthComponent

# When the action-key is pressed, demonstrate how to use an RPC to execute action.

@onready var side_kick_input_controller = $SideKickInputController
@onready var _hitbox_component: HitboxComponent = $HitboxComponent
#var input_dir: Vector2
var spent = false


func _ready() -> void:
	super._ready()	
	_hitbox_component.hit_hurtbox.connect(_hit_hurtbox)

func _physics_process(delta: float) -> void:
	if get_tree().get_multiplayer().has_multiplayer_peer() and is_multiplayer_authority() and not MatchManager.game_paused and not player_tagged.tagged_player_name == "" and not spent:
		#input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var input_dir = side_kick_input_controller.input_dir
		var velocity: Vector2 = Vector2(input_dir.x, input_dir.y) * 900
		translate(velocity * delta)

# When mine hit, remove it.
func _hit_hurtbox(_hurtbox: HurtboxComponent) -> void:
	spent = true
	pickup_sprite.animation = "explode"
	
	# TODO: this does not clean up if the authority was taken by a non-auth-peer
	if is_multiplayer_authority() and not pickup_sprite.animation_finished.has_connections():
		pickup_sprite.animation_finished.connect(queue_free)
