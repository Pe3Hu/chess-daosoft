class_name Referee
extends PanelContainer


@export var game: Game

var resource: RefereeResource:
	set(value_):
		resource = value_
		init_clocks()

@onready var clocks = %Clocks


#region clock
func init_clocks() -> void:
	for player_resource in resource.players:
		match player_resource.color:
			FrameworkSettings.PieceColor.WHITE:
				%WhiteClock.resource = player_resource.clock
			FrameworkSettings.PieceColor.BLACK:
				%BlackClock.resource = player_resource.clock
	
	update_clocks()
	
func update_clocks() -> void:
	for clock in clocks.get_children():
		clock.update_time_label()
		clock.update_sacrifice_label()
		clock.sacrifice_box.visible = FrameworkSettings.active_mode == FrameworkSettings.ModeType.GAMBIT
		
func get_player_clock(player_resource_: PlayerResource) -> Variant:
	for clock in clocks.get_children():
		if clock.resource == player_resource_.clock:
			return clock
	
	return null
#endregion
	
func start_game() -> void:
	game.on_pause = false
	game.board.checkmate_panel.visible = false
	visible = true
	%WhiteClock._on_switch()
	
func pass_turn_to_opponent() -> void:
	#game.board.reset_state_tiles()
	#apply_mods()
	resource.pass_turn_to_opponent()
	
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
	game.receive_move(random_move)
	
func reset() -> void:
	resource.reset()
	update_clocks()
	
#region mod
func apply_mods() -> void:
	apply_void_mod()
	apply_hellhorse_mod()
	apply_spy_mod()
	
func apply_void_mod() -> void:
	if FrameworkSettings.active_mode != FrameworkSettings.ModeType.VOID: return
	var escape_piece_resources = []
	
	for move_resource in resource.active_player.opponent.capture_moves:
		if !escape_piece_resources.has(move_resource.captured_piece):
			escape_piece_resources.append(move_resource.captured_piece)
	
	for piece_resource in escape_piece_resources:
		if piece_resource.failure_on_escape_trial():
			var piece = game.board.get_piece(piece_resource)
			piece.capture()
	
func apply_hellhorse_mod() -> void:
	if FrameworkSettings.active_mode != FrameworkSettings.ModeType.HELLHORSE: return
	var last_move = game.notation.resource.moves.back()
	if last_move.piece.template.type != FrameworkSettings.PieceType.HELLHORSE: return
	var initiative = last_move.piece.player.get_initiative()
	
	match initiative:
		FrameworkSettings.InitiativeType.BASIC:
			last_move.piece.player.initiatives.push_back(FrameworkSettings.InitiativeType.HELLHORSE)
		
			last_move.piece.player.generate_legal_moves()
			game.board.clear_phantom_hellhorse_captures()
		FrameworkSettings.InitiativeType.HELLHORSE:
			pass
	
func apply_spy_mod() -> void:
	if FrameworkSettings.active_mode != FrameworkSettings.ModeType.SPY: return
	#if game.notation.resource.moves.size() < 2: return
	
	#var initiative = resource.active_player.get_initiative()
	#match initiative:
		#FrameworkSettings.InitiativeType.BASIC:
			#resource.active_player.generate_legal_moves()
			#game.board.reset_state_tiles()
		#FrameworkSettings.InitiativeType.SPY:
			#pass
	
func fox_mod_preparation() -> void:
	resource.fox_swap_players.append_array(resource.players)
	
	for player in resource.players:
		player.fill_fox_swap_pieces()
	
	game.menu.update_bots()
	game.board.fox_mod_tile_state_update()
	
func apply_opponent_spy_move() -> void:
	var move = resource.active_player.opponent.spy_move
	if move == null: return
	
	if !check_spy_move_is_legal():
		return
	
	move.is_postponed = false
	#if move.type == FrameworkSettings.MoveType.CASTLING:
		#if !check_spy_move_on_legal_castling():
			#return
	
	match move.type:
		#FrameworkSettings.MoveType.CASTLING:
			#if !check_spy_move_on_legal_castling():
				#return
		FrameworkSettings.MoveType.CAPTURE:
			move.is_postponed = !check_spy_move_on_legal_capture()
		FrameworkSettings.MoveType.PASSANT:
			move.is_postponed = !check_spy_move_on_legal_capture()
	
	update_spy_move_on_slide_capture()
	
	game.receive_move(move)
	var spy_piece = game.board.get_piece(move.piece)
	
	if move.castling_rook != null:
		spy_piece.complement_castling_move(move)
	
	detect_spy_checkmate()
	
func check_spy_move_is_legal() -> bool:
	resource.active_player.find_threat_moves()
	resource.active_player.opponent.generate_legal_moves()
	
	for move in resource.active_player.opponent.legal_moves:
		if resource.active_player.opponent.spy_move.check_is_equal(move):
			return true
	
	return false
	
#func check_spy_move_on_legal_castling() -> bool:
	#var move = resource.active_player.opponent.spy_move
	#if move.castling_rook == null: return false
	##var tile_on_threat = false
	##var rook = move.castling_rook
	#return move.check_slide_tiles_on_threat()
	
func check_spy_move_on_legal_capture() -> bool:
	var move = resource.active_player.opponent.spy_move
	if move.end_tile.piece != move.captured_piece:
		move.type = FrameworkSettings.MoveType.BASIC
		move.captured_piece = null
	
	return move.piece.template.type != FrameworkSettings.PieceType.PAWN
	
func update_spy_move_on_slide_capture() -> void:
	var move = resource.active_player.opponent.spy_move
	var end_of_slide_tile_resource = move.get_tile_after_slide()
	
	if move.end_tile != end_of_slide_tile_resource:
		move.end_tile = end_of_slide_tile_resource
	
	if move.end_tile.piece != null:
		move.captured_piece = move.end_tile.piece
		move.type = FrameworkSettings.MoveType.CAPTURE
	
func detect_spy_checkmate() -> void:
	resource.active_player.opponent.find_threat_moves()
	if resource.active_player.opponent.can_apply_checkmate():
	#if !resource.active_player.opponent.check_moves.is_empty():
		resource.winner_player = resource.active_player.opponent
		game.end()
	
	
func apply_opponent_spy_move_old() -> void:
	if resource.active_player.opponent.spy_move == null: return
	var spy_piece_resource = resource.active_player.opponent.spy_move.piece
	var spy_piece = game.board.get_piece(spy_piece_resource)
	var is_capturing = resource.active_player.opponent.spy_move.captured_piece != null
	var castling_rook = resource.active_player.opponent.spy_move.castling_rook
	var end_of_slide_tile_resource = resource.get_tile_after_slide()
	resource.active_player.opponent.spy_move = null
	
	if end_of_slide_tile_resource.piece != null:
		var captured_piece = game.board.get_piece(end_of_slide_tile_resource.piece)
		
		if spy_piece != captured_piece:
			captured_piece.capture(spy_piece, true)
	
	var spy_tile = game.board.get_tile(end_of_slide_tile_resource)
	
	if is_capturing:
		if spy_tile.resource.piece != null and spy_piece.template.type == FrameworkSettings.PieceType.PAWN:
			spy_piece.place_on_tile(spy_tile)
	else:
		spy_piece.place_on_tile(spy_tile)
	
	if castling_rook != null:
		spy_piece.complement_castling_move(castling_rook)
	
	#resource.is_spy_action = true
	#spy_piece.place_on_tile(spy_tile)
	#resource.is_spy_action = false
	
	var tile_resource_on_reset = []
	for capture_move in spy_piece_resource.player.capture_moves:
		if !tile_resource_on_reset.has(capture_move.end_tile):
			tile_resource_on_reset.append(capture_move.end_tile)
	
	game.board.reset_tiles(tile_resource_on_reset)
	
	game.recalc_piece_environment()
	#spy_piece_resource.player.unfresh_all_pieces()
	#spy_piece_resource.player.find_threat_moves()
	#spy_piece_resource.player.opponent.unfresh_all_pieces()
	#spy_piece_resource.player.opponent.generate_legal_moves()
	#game.board.reset_focus_tile()
	#game.board.reset_tiles()
#endregion
