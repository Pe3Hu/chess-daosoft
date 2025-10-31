class_name Referee
extends PanelContainer


@export var game: Game

var resource: RefereeResource:
	set(value_):
		resource = value_
		init_clocks()

@onready var clocks = %Clocks


func init_clocks() -> void:
	for player_resource in resource.players:
		match player_resource.color:
			FrameworkSettings.PieceColor.WHITE:
				%WhiteClock.resource = player_resource.clock
			FrameworkSettings.PieceColor.BLACK:
				%BlackClock.resource = player_resource.clock
	
	update_clocks()
	
func start_game() -> void:
	game.on_pause = false
	game.checkmate_panel.visible = false
	visible = true
	
	%WhiteClock._on_switch()
	
func pass_initiative() -> void:
	game.board.reset_initiative_tile()
	resource.pass_initiative()
	
	if !check_gameover():
		game.board.reset_focus_tile()
		
		for clock in clocks.get_children():
			clock._on_switch()
		
		apply_bot_move()
	
func check_gameover() -> bool:
	var is_gameover = resource.winner_player != null
	
	if !is_gameover:
		is_gameover = resource.active_player.legal_moves.is_empty()
		
		if is_gameover:
			resource.winner_player = resource.active_player.opponent
	
	if is_gameover:
		game.end()
		return true
		
	return false
	
func apply_bot_move() -> void:
	if !resource.active_player.is_bot: return
	
	var random_move = resource.active_player.legal_moves.pick_random()
	game.board.apply_move(random_move)
	
func update_clocks() -> void:
	for clock in clocks.get_children():
		clock.update_label()
	
func reset() -> void:
	resource.reset()
	update_clocks()
