class_name Game
extends PanelContainer


signal fox_swap_pieces_finished

@export var cursor: CustomCursor

var resource: GameResource = GameResource.new()

@onready var board = %Board
@onready var referee = %Referee
@onready var notation = %Notation
@onready var menu = %Menu
@onready var checkmate_panel = %CheckmatePanel
@onready var checkmate_label = %CheckmateLabel

var on_pause: bool = true


func _ready() -> void:
	board.resource = resource.board
	referee.resource = resource.referee
	notation.resource = resource.notation
	
	board.initial_tile_state_update()
	await get_tree().create_timer(0.05).timeout
	start()
	
func start() -> void:
	menu.mods.visible = false
	menu.start_game_button.visible = false
	menu.handbook.visible = true
	board.visible = true
	notation.visible = true
	
	match resource.current_mod:
		FrameworkSettings.ModeType.FOX:
			referee.fox_mod_preparation()
			menu.fox_mod_display(true)
			await fox_swap_pieces_finished
			menu.fox_mod_display(false)
			await get_tree().create_timer(0.05).timeout
		FrameworkSettings.ModeType.GAMBIT:
			if FrameworkSettings.BOARD_SIZE != FrameworkSettings.GAMBIT_BOARD_SIZE:
				FrameworkSettings.BOARD_SIZE = FrameworkSettings.GAMBIT_BOARD_SIZE
				board.resize()
	
	on_pause = false
	
	referee.start_game()
	menu.update_bots()
	
	if referee.resource.winner_player != null:
		reset()
	
	if referee.resource.active_player.is_bot:
		referee.apply_bot_move()
	
func end() -> void:
	menu.handbook.visible = false
	menu.mods.visible = true
	menu.start_game_button.visible = true
	referee.visible = false
	var notification_text = ""
	
	match referee.resource.winner_player.color:
		FrameworkSettings.PieceColor.BLACK:
			notification_text = "Black"
		FrameworkSettings.PieceColor.WHITE:
			notification_text = "White"
	
	notification_text += " is winner"
	checkmate_panel.visible = true
	checkmate_label.text = notification_text
	
	for clock in referee.clocks.get_children():
		clock.tick_timer.stop()
	
func reset() -> void:
	referee.reset()
	notation.reset()
	board.reset()
	menu.update_bots()
