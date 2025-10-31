class_name PlayerResource
extends Resource


var referee: RefereeResource
var board: BoardResource
var opponent: PlayerResource
var clock: ClockResource = ClockResource.new(self)

var color: FrameworkSettings.PieceColor = FrameworkSettings.PieceColor.WHITE

var pieces: Array[PieceResource]
var king_piece: PieceResource

var legal_moves: Array[MoveResource]
var threat_moves: Array[MoveResource]
var threat_tiles: Array[TileResource]
var capture_moves: Array[MoveResource]
var pin_moves: Array[MoveResource]
var pin_pieces: Array[PieceResource]
var check_moves: Array[MoveResource]
var check_tiles: Array[TileResource]
var piece_to_assist: Dictionary

var is_winner: bool = false
var is_bot: bool = false


func _init(referee_: RefereeResource, color_: FrameworkSettings.PieceColor) -> void:
	referee = referee_
	color = color_ 
	
func generate_moves() -> Array:
	var moves = []
	
	for piece in pieces:
		piece.geterate_moves()
		moves.append_array(piece.moves)
	
	return moves
	
func generate_legal_moves() -> void:
	if referee.game.board == null: return
	legal_moves.clear()
	piece_to_assist = {}
	
	generate_king_legal_moves()
	if opponent.check_moves.size() > 1: return
	
	for piece in pieces:
		if piece != king_piece:
			piece.geterate_moves()
			var piece_legal_moves = piece.moves
			
			if !piece.pin_tiles.is_empty():
				piece_legal_moves = piece_legal_moves.filter(func (a): return piece.pin_tiles.has(a.end_tile))
			if !opponent.check_tiles.is_empty():
				piece_legal_moves = piece_legal_moves.filter(func (a): return opponent.check_tiles.has(a.end_tile))
			legal_moves.append_array(piece_legal_moves)
	
func generate_king_legal_moves() -> void:
	king_piece.geterate_moves()
	var king_legal_moves = king_piece.moves.filter(func (a): return !opponent.threat_tiles.has(a.end_tile))
	king_legal_moves = king_legal_moves.filter(func (a): return !opponent.piece_to_assist.keys().has(a.captured_piece))
	legal_moves.append_array(king_legal_moves)
	
func generate_legal_moves_old() -> void:
	if referee.game.board == null: return
	legal_moves.clear()
	var pseudo_legal_moves = generate_moves()
	
	for pseudo_legal_move in pseudo_legal_moves:
		referee.game.board.make_move(pseudo_legal_move)#, true)
		
		if !opponent.can_apply_checkmate():#opponent.generate_moves()):
			legal_moves.append(pseudo_legal_move)
			#print([pseudo_legal_move.end_tile.coord])
		
		referee.game.board.unmake_move(pseudo_legal_move)
	
func can_apply_checkmate() -> bool:#moves_: Array) -> bool:
	var moves_ = generate_moves()
	for move in moves_:#legal_moves:#moves_:
		if move.captured_piece != null:
			if move.captured_piece.template.type == FrameworkSettings.PieceType.KING:
				return true
	
	return false
	
func is_legal_move(move_: MoveResource) -> bool:
	for move in legal_moves:
		if move.start_tile == move_.start_tile and move.end_tile == move_.end_tile and move.piece == move_.piece:
			return true
		#if move.start_tile != move_.start_tile:
			#break
		#elif move.end_tile != move_.end_tile:
			#break
	
	return false
	
func unfresh_all_pieces() -> void:
	for piece in pieces:
		piece.is_fresh = false
	
func find_threat_moves() -> void:
	threat_moves.clear()
	threat_tiles.clear()
	capture_moves.clear()
	
	for piece in pieces:
		if !opponent.pin_pieces.has(piece):
			piece.geterate_moves()
			threat_moves.append_array(piece.moves)
			
			for move in piece.moves:
				if !threat_tiles.has(move.end_tile):
					threat_tiles.append(move.end_tile)
			
			var piece_capture_moves = piece.get_capture_moves()
			capture_moves.append_array(piece_capture_moves)
	
	find_check_moves()
	find_pin_moves()
	
func find_check_moves() -> void:
	check_moves.clear()
	
	for capture_move in capture_moves:
		if capture_move.captured_piece == opponent.king_piece:
			check_moves.append(capture_move)
	
	find_check_tiles()
	
func find_pin_moves() -> void:
	pin_moves.clear()
	pin_pieces.clear()
	
	for capture_move in capture_moves:
		var pin_tiles = is_king_behind_piece(capture_move)
		
		if !pin_tiles.is_empty():
			pin_moves.append(capture_move)
			pin_pieces.append(capture_move.captured_piece)
			capture_move.captured_piece.set_pin_tiles(pin_tiles)
			capture_move.captured_piece.pin_source_piece = capture_move.piece
			capture_move.piece.pin_target_piece = capture_move.captured_piece
	
	#var test_pin_pieces = pieces.filter(func(a): return a.pin_piece != null)
	#
	#for piece in test_pin_pieces:
		#print([piece.tile.id, piece.pin_piece.tile.id])
	
func is_king_behind_piece(capture_move_: MoveResource) -> Array:
	if !FrameworkSettings.SLIDE_PIECES.has(capture_move_.piece.template.type): return []
	if capture_move_.captured_piece == opponent.king_piece: return []
	
	var king_direction = opponent.king_piece.tile.coord - capture_move_.start_tile.coord
	if !check_on_axis(king_direction): return []
	var unit_king_direction = get_unit_vector(king_direction)
	var unit_pin_direction = get_unit_vector(capture_move_.end_tile.coord - capture_move_.start_tile.coord)
	if king_direction != unit_pin_direction: return []
	
	var tile_on_way_to_king = capture_move_.start_tile
	var pint_tiles = []
	
	while tile_on_way_to_king != opponent.king_piece.tile:
		pint_tiles.append(tile_on_way_to_king)
		var next_tile_coord = tile_on_way_to_king.coord + unit_king_direction
		tile_on_way_to_king = board.get_tile_based_on_coord(next_tile_coord)
		if tile_on_way_to_king == null: break
		
		if tile_on_way_to_king.piece == capture_move_.captured_piece: continue
		elif tile_on_way_to_king.piece != null:
			if tile_on_way_to_king.piece != opponent.king_piece: return []
	
	return pint_tiles
	
func find_check_tiles() -> void:
	check_tiles.clear()
	if check_moves.size() != 1: return
	var check_move = check_moves.front()
	
	if !FrameworkSettings.SLIDE_PIECES.has(check_move.piece.template.type):
		check_tiles.append(check_move.start_tile)
		return
	
	var check_direction = get_unit_vector(check_move.end_tile.coord - check_move.start_tile.coord)
	var tile_on_way_to_king = check_move.start_tile
	
	while tile_on_way_to_king != opponent.king_piece.tile:
		check_tiles.append(tile_on_way_to_king)
		var next_tile_coord = tile_on_way_to_king.coord + check_direction
		tile_on_way_to_king = board.get_tile_based_on_coord(next_tile_coord)
	
func get_unit_vector(vec_: Vector2i) -> Vector2i:
	var x = sign(vec_.x)
	var y = sign(vec_.y)
	return Vector2i(x, y)
	
func check_on_axis(vec_: Vector2i) -> bool:
	if vec_.x == 0 or vec_.y == 0: return true
	return vec_.x == vec_.y
	
func reset() -> void:
	clock.reset()
	
	legal_moves.clear()
	threat_moves.clear()
	threat_tiles.clear()
	capture_moves.clear()
	pin_moves.clear()
	pin_pieces.clear()
	check_moves.clear()
	check_tiles.clear()
	piece_to_assist = {}
	
	is_winner = false
	is_bot = false
