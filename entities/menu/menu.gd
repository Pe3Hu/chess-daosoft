class_name Menu
extends PanelContainer


@export var game: Game

@onready var mods: VBoxContainer = %Mods
@onready var classic_button: CheckButton = %ClassicCheckButton
@onready var hell_horse_button: CheckButton = %HellHorseCheckButton
@onready var void_button: CheckButton = %VoidCheckButton
@onready var fox_button: CheckButton = %FoxCheckButton
@onready var spy_button: CheckButton = %SpyCheckButton
@onready var gambit_button: CheckButton = %GambitCheckButton
@onready var active_button: CheckButton = classic_button:
	set(value_):
		if active_button != null:
			active_button.button_pressed = false
			active_button.disabled = false
		
		active_button = value_
		active_button.disabled = true

@onready var option_buttons: VBoxContainer = %OptionButtons
@onready var auto_white_button: CheckButton = %AutoWhiteCheckButton
@onready var auto_black_button: CheckButton = %AutoBlackCheckButton
@onready var start_game_button: Button = %StartGameButton

@onready var fox_label: Label = %FoxLabel
@onready var handbook: Handbook = %Handbook


func _ready() -> void:
	#active_button = classic_button
	#game.resource.current_mod = FrameworkSettings.ModeType.CLASSIC
	active_button = gambit_button
	game.resource.current_mod = FrameworkSettings.ModeType.GAMBIT
	active_button.button_pressed = true
	
func _on_classic_check_button_pressed() -> void:
	if classic_button.button_pressed:
		active_button = classic_button
		game.resource.current_mod = FrameworkSettings.ModeType.CLASSIC
	
func _on_hell_horse_check_button_pressed() -> void:
	if hell_horse_button.button_pressed:
		active_button = hell_horse_button
		game.resource.current_mod = FrameworkSettings.ModeType.HELLHORSE
	
func _on_void_check_button_pressed() -> void:
	if void_button.button_pressed:
		active_button = void_button
		game.resource.current_mod = FrameworkSettings.ModeType.VOID
	
func _on_gambit_check_button_pressed() -> void:
	if gambit_button.button_pressed:
		active_button = gambit_button
		game.resource.current_mod = FrameworkSettings.ModeType.GAMBIT
	
func _on_fox_check_button_pressed() -> void:
	if fox_button.button_pressed:
		active_button = fox_button
		game.resource.current_mod = FrameworkSettings.ModeType.FOX
	
func _on_spy_check_button_pressed() -> void:
	if spy_button.button_pressed:
		active_button = spy_button
		game.resource.current_mod = FrameworkSettings.ModeType.SPY

func _on_auto_white_check_button_pressed() -> void:
	if auto_black_button.button_pressed:
		auto_black_button.button_pressed = false
	
	update_bots()
	if game.on_pause: return
	
	if game.referee.resource.active_player.is_bot:
		game.referee.apply_bot_move()
	
func _on_auto_black_check_button_pressed() -> void:
	if auto_white_button.button_pressed:
		auto_white_button.button_pressed = false
	
	update_bots()
	if game.on_pause: return
	
	if game.referee.resource.active_player.is_bot:
		game.referee.apply_bot_move()
	
func _on_start_game_button_pressed() -> void:
	game.start()
	
func update_bots() -> void:
	game.referee.resource.color_to_player[FrameworkSettings.PieceColor.WHITE].is_bot = auto_white_button.button_pressed
	game.referee.resource.color_to_player[FrameworkSettings.PieceColor.BLACK].is_bot = auto_black_button.button_pressed
	
func fox_mod_display(is_on_: bool) -> void:
	#option_buttons.visible = !is_on_
	fox_label.visible = is_on_
	handbook.pin.visible = !is_on_
	handbook.capture.visible = !is_on_
	handbook.check.visible = !is_on_
