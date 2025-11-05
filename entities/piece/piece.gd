class_name Piece
extends Sprite2D


var board: Board
var resource: PieceResource:
	set(value_):
		resource = value_
		
		update_sprite()
		position = Vector2(resource.tile.coord) * FrameworkSettings.TILE_SIZE

@export_enum("pawn", "king", "queen", "rook", "bishop", "knight", "hellhorse") var type = "pawn":
	set(value_):
		type = value_
		
		if color != null:
			texture = load("res://entities/piece/images/" + color + "_" + type + ".png")
		if type == "hellhorse":
			offset.y = 5
@export_enum("black", "white") var color = "white":
	set(value_):
		color = value_
		
		if type != null:
			texture = load("res://entities/piece/images/" + color + "_" + type + ".png")

var is_holden: bool:
	set(value_):
		is_holden = value_
		
		if is_holden:
			z_index = 1
		else:
			z_index = 0


func update_sprite() -> void:
	type = resource.get_type()
	color = resource.get_color()
	
func _process(_delta: float) -> void:
	if is_holden:
		global_position = get_global_mouse_position()
	
func place_on_tile(tile_: Tile) -> void:
	#if resource.player.spy_move != null: return
	if resource.tile != null:
		resource.tile.piece = null
	
	var move_resource = resource.get_move(tile_.resource)
	var is_passing_initiative = move_resource != null
	
	if move_resource != null:
		if resource.is_inactive:
			resource.is_inactive = false
		
		#ignoring rook move after king castling
		is_passing_initiative = board.game.resource.notation.record_move(move_resource)
		
		match move_resource.type:
			FrameworkSettings.MoveType.CAPTURE:
				var captured_piece = board.get_piece(move_resource.captured_piece)
				captured_piece.capture(self)
			FrameworkSettings.MoveType.PASSANT:
				var captured_piece = board.get_piece(move_resource.captured_piece)
				captured_piece.capture(self)
			FrameworkSettings.MoveType.PROMOTION:
				move_resource.pawn_promotion()
				promotion()
			FrameworkSettings.MoveType.CASTLING:
				complement_castling_move()
		
		##check on Gambit Altar
		sacrifice(move_resource)
	
	board.game.cursor.current_state = FrameworkSettings.CursorState.SELECT
	is_holden = false
	
	var is_canceling_move: bool = false
	
	match board.game.resource.current_mod:
		FrameworkSettings.ModeType.SPY:
			var moves = board.game.notation.resource.moves
			
			if moves.size() > 1 and board.game.referee.resource.active_player.spy_move == null:
				var second_last_move = moves[moves.size()-2]
				#var a = board.game.referee.resource.active_player.color
				#var b = second_last_move.piece.player.color
				
				if second_last_move.piece.player == board.game.referee.resource.active_player:
					board.game.referee.resource.active_player.spy_move = move_resource
					is_canceling_move = true
	
	if board.game.referee.resource.is_spy_action:
		is_canceling_move = false
	
	if !is_canceling_move:
		global_position = tile_.global_position
		tile_.resource.place_piece(resource)
	else:
		var start_tile = board.get_tile(resource.tile)
		global_position = start_tile.global_position
	#else:
	#	cancel_move(move_resource)
	
	#recalculation of moves after castling is completed
	#if !is_not_castling_move:
	#	resource.player.opponent.generate_legal_moves()
	
	board.reset_focus_tile()
	board.resource.focus_tile = null
	
	if is_passing_initiative:
		if !is_canceling_move:
			board.game.notation.add_move(move_resource)
			
			match board.game.resource.current_mod:
				FrameworkSettings.ModeType.SPY:
					board.game.referee.apply_opponent_spy_move()
		
		if !board.game.referee.resource.is_spy_action:
			board.game.referee.pass_initiative()
	elif board.game.referee.resource.active_player.hellhorse_bonus_move:
		board.show_hellhorse_pass_ask()
	
func capture(source_piece_: Piece = null, is_admin_: bool = false) -> void:
	if resource.player.spy_move == null and !is_admin_: return 
	if source_piece_ != null:
		if board.game.resource.current_mod == FrameworkSettings.ModeType.VOID:
			if resource.success_on_stand_trial():
				source_piece_.capture()
				return
	
	board.resource.capture_piece(resource)
	remove_self()
	
func remove_self() -> void:
	#board.resource_to_piece.erase(resource)
	board.pieces.remove_child(self)
	queue_free()
	
func promotion() -> void:
	update_sprite()
	
func complement_castling_move() -> void:
	var move_resource = board.game.resource.notation.moves.back()
	var rook_piece = board.get_piece(move_resource.castling_rook)
	var rook_direction = Vector2(rook_piece.resource.tile.coord - resource.tile.coord).normalized()
	var next_root_tile_coord = resource.tile.coord + Vector2i(rook_direction)
	var next_root_tile_id = FrameworkSettings.BOARD_SIZE.x * next_root_tile_coord.y + next_root_tile_coord.x
	var next_root_tile_resource = board.resource.tiles[next_root_tile_id]
	var next_root_tile = board.get_tile(next_root_tile_resource)
	rook_piece.place_on_tile(next_root_tile)
	
func sacrifice(move_resource_: MoveResource) -> void:
	match board.game.resource.current_mod:
		FrameworkSettings.ModeType.GAMBIT:
			if move_resource_.end_tile != board.resource.altar_tile: return
			resource.player.clock.sacrifices -= 1
			if resource.template.type == FrameworkSettings.PieceType.KING:
				resource.player.clock.sacrifices = 0
			
			var clock = board.game.referee.get_player_clock(resource.player)
			clock.update_sacrifice_label()
			board.game.referee.check_gameover()
			remove_self()
			#var altar_tile = board.get_tile(board.resource.altar_tile)
			#board.resource.altar_tile.piece = null
	
func cancel_move(move_resource_: MoveResource) -> void:
	match board.game.resource.current_mod:
		FrameworkSettings.ModeType.SPY:
			resource.player.spy_move = move_resource_
	
	board.game.resource.notation.cancel_move(move_resource_)
	var old_tile = board.get_tile(move_resource_.start_tile)
	place_on_tile(old_tile)
