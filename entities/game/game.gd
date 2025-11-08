class_name Game
extends PanelContainer


signal fox_swap_pieces_finished

@export var cursor: CustomCursor

var resource: GameResource = GameResource.new()

@onready var board: Board = %Board
@onready var referee: Referee = %Referee
@onready var notation: Notation = %Notation
@onready var menu = %Menu
@onready var handbook: Handbook = %Handbook

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
	menu.surrender_game_button.visible = true
	handbook.visible = true
	handbook.altar.visible = FrameworkSettings.active_mode == FrameworkSettings.ModeType.GAMBIT
	board.visible = true
	board.checkmate_panel.visible = false
	notation.visible = true
	
	FrameworkSettings.BOARD_SIZE = FrameworkSettings.mod_to_board_size[FrameworkSettings.active_mode]
	
	if FrameworkSettings.BOARD_SIZE.x * FrameworkSettings.BOARD_SIZE.y != board.resource.tiles.size():
		board.resize()
	
	if referee.resource.winner_player != null:
		reset()
	elif board.resource.start_fen != FrameworkSettings.mod_to_fen[FrameworkSettings.active_mode]:
		reset()
	else :
		#resource.before_first_move()
		recalc_piece_environment()
		#board.resource.load_start_position()
	
	on_pause = true
	
	match FrameworkSettings.active_mode:
		FrameworkSettings.ModeType.FOX:
			referee.fox_mod_preparation()
			handbook.fox_mod_display(true)
			await fox_swap_pieces_finished
			handbook.fox_mod_display(false)
			await get_tree().create_timer(0.05).timeout
	
	on_pause = false
	referee.start_game()
	menu.update_bots()
	
	if referee.resource.active_player.is_bot:
		referee.apply_bot_move()
	
func end() -> void:
	handbook.visible = false
	menu.mods.visible = true
	menu.start_game_button.visible = true
	menu.surrender_game_button.visible = false
	referee.visible = false
	var notification_text = ""
	
	match referee.resource.winner_player.color:
		FrameworkSettings.PieceColor.BLACK:
			notification_text = "Black"
		FrameworkSettings.PieceColor.WHITE:
			notification_text = "White"
	
	notification_text += " is winner"
	board.checkmate_panel.visible = true
	board.checkmate_label.text = notification_text
	
	for clock in referee.clocks.get_children():
		clock.tick_timer.stop()
	
func reset() -> void:
	referee.reset()
	notation.reset()
	board.reset()
	menu.update_bots()
	resource.before_first_move()
	
func surrender() -> void:
	resource.referee.winner_player = resource.referee.active_player.opponent
	handbook.surrender_reset()
	end()
	
func recalc_piece_environment() -> void:
	resource.recalc_piece_environment()
	board.reset_focus_tile()
	
