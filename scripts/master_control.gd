extends Node2D

@onready var game_controller = $GameController
@onready var ingame_overlay = $IngameOverlay
@onready var title_screen = $TitleScreen

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

var init = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if init:
		# UI signals
		game_controller.player.changed_spell_type.connect(ingame_overlay.set_current_spell_tex)
		game_controller.player.fireball_charges.connect(ingame_overlay.set_fire_charges)
		game_controller.player.waterball_charges.connect(ingame_overlay.set_water_charges)
		game_controller.player.attack_cooldown_percentage.connect(ingame_overlay.set_attack_cooldown_bar)
		game_controller.player.health_module.hp_change.connect(ingame_overlay.set_health_bar)
		game_controller.dungeon.enemy_dead.connect(ingame_overlay.set_enemy_kill_progress_bar)
		game_controller.room_change.connect(ingame_overlay.set_minimap_rooms)
		game_controller.player.health_module.take_damage(0)
		
		game_controller.player.health_module.lethal_damage_taken.connect(loose)
		game_controller.win.connect(win)
		
		title_screen.game_start.connect(start_game)
		
		$Pause_Menu.visible = false
		$EndScreen_Loose.visible = false
		$EndScreen_Win.visible = false
		$TitleScreen.visible = true
		
		init = false
	
	if Input.is_action_just_pressed("toggle_pause"):
		if not ($EndScreen_Loose.visible or $EndScreen_Win.visible or title_screen.visible):
			if $Pause_Menu.visible:
				$Pause_Menu.visible = false
				get_tree().paused = false
			else:
				$Pause_Menu.visible = true
				get_tree().paused = true

func start_game():
	$EndScreen_Loose.visible = false
	$EndScreen_Win.visible = false
	$TitleScreen.visible = false
	$Pause_Menu.visible = false
	get_tree().paused = false
	game_controller.reset()
				
func loose():
	$EndScreen_Loose.visible = true
	get_tree().paused = true

func win():
	$EndScreen_Win.visible = true
	get_tree().paused = true
