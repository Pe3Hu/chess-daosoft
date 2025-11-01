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
	game.board.checkmate_panel.visible = false
	visible = true
	
	%WhiteClock._on_switch()
	
func pass_initiative() -> void:
	game.board.reset_initiative_tile()
	apply_mods()
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
		clock.update_time_label()
		clock.update_sacrifice_label()
		clock.sacrifice_box.visible = game.resource.current_mod == FrameworkSettings.ModeType.GAMBIT
		
func reset() -> void:
	resource.reset()
	update_clocks()
	
func apply_mods() -> void:
	apply_void_mod()
	apply_hellhorse_mod()
	
func apply_void_mod() -> void:
	if game.resource.current_mod != FrameworkSettings.ModeType.VOID: return
	var escape_piece_resources = []
	
	for move_resource in resource.active_player.opponent.capture_moves:
		if !escape_piece_resources.has(move_resource.captured_piece):
			escape_piece_resources.append(move_resource.captured_piece)
	
	for piece_resource in escape_piece_resources:
		if piece_resource.failure_on_escape_trial():
			var piece = game.board.get_piece(piece_resource)
			piece.capture()
	
func apply_hellhorse_mod() -> void:
	if game.resource.current_mod != FrameworkSettings.ModeType.HELLHORSE: return
	var last_move = game.notation.resource.moves.back()
	if last_move.piece.template.type != FrameworkSettings.PieceType.HELLHORSE: return
	if last_move.piece.player.hellhorse_bonus_move:
		last_move.piece.player.hellhorse_bonus_move = false
	else:
		last_move.piece.player.hellhorse_bonus_move = true
		last_move.piece.player.generate_legal_moves()
		game.board.clear_phantom_hellhorse_captures()
	
func fox_mod_preparation() -> void:
	resource.fox_swap_players.append_array(resource.players)
	
	for player in resource.players:
		player.fill_fox_swap_pieces()
	
	game.menu.update_bots()
	game.board.fox_mod_tile_state_update()
	
func get_player_clock(player_resource_: PlayerResource) -> Variant:
	for clock in clocks.get_children():
		if clock.resource == player_resource_.clock:
			return clock
	
	return null
