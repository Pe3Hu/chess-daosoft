class_name Menu
extends PanelContainer


@export var game: Game

@onready var mods: VBoxContainer = %Mods
@onready var classic_button: CheckButton = %ClassicCheckButton
@onready var hell_horse_button: CheckButton = %HellHorseCheckButton
@onready var void_button: CheckButton = %VoidCheckButton
@onready var active_button: CheckButton:
	set(value_):
		if active_button != null:
			active_button.button_pressed = false
			active_button.disabled = false
		
		active_button = value_
		active_button.disabled = true

@onready var auto_white_button: CheckButton = %AutoWhiteCheckButton
@onready var auto_black_button: CheckButton = %AutoBlackCheckButton
@onready var start_game_button: Button = %StartGameButton


func _ready() -> void:
	active_button = classic_button
	
func _on_classic_check_button_pressed() -> void:
	if classic_button.button_pressed:
		active_button = classic_button
	
func _on_hell_horse_check_button_pressed() -> void:
	if hell_horse_button.button_pressed:
		active_button = hell_horse_button
	
func _on_void_check_button_pressed() -> void:
	if void_button.button_pressed:
		active_button = void_button
	
func _on_auto_white_check_button_pressed() -> void:
	if auto_black_button.button_pressed:
		auto_black_button.button_pressed = false
	
	update_bots()
	
	if game.referee.resource.active_player.is_bot:
		game.referee.apply_bot_move()
	
func _on_auto_black_check_button_pressed() -> void:
	if auto_white_button.button_pressed:
		auto_white_button.button_pressed = false
	
	update_bots()
	
	if game.referee.resource.active_player.is_bot:
		game.referee.apply_bot_move()
	
func _on_start_game_button_pressed() -> void:
	start_game()
	
func start_game() -> void:
	mods.visible = false
	start_game_button.visible = false
	game.referee.start_game()
	update_bots()
	game.on_pause = false
	
	if game.referee.resource.winner_player != null:
		game.reset()
	
	if game.referee.resource.active_player.is_bot:
		game.referee.apply_bot_move()
	
func update_bots() -> void:
	game.referee.resource.color_to_player[FrameworkSettings.PieceColor.WHITE].is_bot = auto_white_button.button_pressed
	game.referee.resource.color_to_player[FrameworkSettings.PieceColor.BLACK].is_bot = auto_black_button.button_pressed
