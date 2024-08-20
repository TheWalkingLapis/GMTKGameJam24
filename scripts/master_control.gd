extends Node2D

@onready var game_controller = $GameController
@onready var ingame_overlay = $IngameOverlay
@onready var title_screen = $TitleScreen
@onready var music_player = $MusicPlayer

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
		game_controller.dungeon.set_progress_zero.connect(ingame_overlay.set_enemy_kill_progress_bar)
		game_controller.layer_change.connect(ingame_overlay.set_floor)
		game_controller.room_change.connect(ingame_overlay.set_minimap_rooms)
		game_controller.player.health_module.take_damage(0)
		
		game_controller.player.health_module.lethal_damage_taken.connect(loose)
		game_controller.win.connect(win)
		
		title_screen.game_start.connect(start_game)
		title_screen.settings.connect(toggle_settings)
		
		$Pause_Menu.visible = false
		$EndScreen_Loose.visible = false
		$EndScreen_Win.visible = false
		$Settings_Menu.visible = false
		$Settings.visible = false
		$TitleScreen.visible = true
		
		init = false
	
	if Input.is_action_just_pressed("toggle_fullscreen"):
		toggle_fullscreen()
	
	if Input.is_action_just_pressed("toggle_pause"):
		toggle_pause()

func set_sound_effect_volume(percentage: float):
	var val = linear_to_db(percentage)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SoundEffects"), val)

func set_music_volume(percentage: float):
	var val = linear_to_db(percentage)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), val)


func to_title():
	$EndScreen_Loose.visible = false
	$EndScreen_Win.visible = false
	$TitleScreen.visible = true
	$Pause_Menu.visible = false
	$Settings.visible = false
	$Settings_Menu.visible = false
	get_tree().paused = true

func toggle_settings():
	if $Settings_Menu.visible:
		$Settings_Menu.visible = false
		$Settings.visible = false
		
		game_controller.visible = true
		$IngameOverlay.visible = true
		$Edge_Blur.visible = true
		title_screen.visible = true
	else:
		$Settings_Menu.visible = true
		$Settings.visible = true
		
		game_controller.visible = false
		$IngameOverlay.visible = false
		$Edge_Blur.visible = false
		title_screen.visible = false
	
func toggle_pause():
	if not ($EndScreen_Loose.visible or $EndScreen_Win.visible or title_screen.visible or $Settings_Menu.visible):
			if $Pause_Menu.visible:
				$Pause_Menu.visible = false
				$Settings.visible = false
				get_tree().paused = false
			else:
				$Pause_Menu.visible = true
				$Settings.visible = true
				get_tree().paused = true

func toggle_fullscreen():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func start_game():
	$EndScreen_Loose.visible = false
	$EndScreen_Win.visible = false
	$TitleScreen.visible = false
	$Pause_Menu.visible = false
	$Settings.visible = false
	$Settings_Menu.visible = false
	get_tree().paused = false
	game_controller.reset()
				
func loose():
	$EndScreen_Loose.visible = true
	get_tree().paused = true

func win():
	$EndScreen_Win.visible = true
	get_tree().paused = true
