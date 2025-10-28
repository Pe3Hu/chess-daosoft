class_name PieceResource
extends Resource


var board: BoardResource
var template: PieceTemplateResource
var tile: TileResource

var moves: Array[MoveResource]
var is_inactive: bool = true


func _init(board_: BoardResource, template_: PieceTemplateResource, tile_: TileResource) -> void:
	board = board_
	template = template_
	tile_.place_piece(self)
	
func get_type() -> String:
	match template.type:
		FrameworkSettings.PieceType.KING:
			return "king"
		FrameworkSettings.PieceType.PAWN:
			return "pawn"
		FrameworkSettings.PieceType.BISHOP:
			return "bishop"
		FrameworkSettings.PieceType.KNIGHT:
			return "knight"
		FrameworkSettings.PieceType.ROOK:
			return "rook"
		FrameworkSettings.PieceType.QUEEN:
			return "queen"
	
	return ""
	
func get_color() -> String:
	match template.color:
		FrameworkSettings.PieceColor.WHITE:
			return "white"
		FrameworkSettings.PieceColor.BLACK:
			return "black"
	
	return ""
	
func geterate_legal_moves() -> void:
	moves.clear()
	
	if template.type == FrameworkSettings.PieceType.PAWN:
		geterate_pawn_moves()
		return
	if template.type == FrameworkSettings.PieceType.KNIGHT:
		geterate_knight_moves()
		return
	
	geterate_sliding_moves()
	
	if template.type == FrameworkSettings.PieceType.KING:
		generate_king_castling_moves()
		return
	
func generate_king_castling_moves() -> void:
	if !is_inactive: return
	var castling_offset_indexs = [2, 6]
	
	for castling_offset_index in castling_offset_indexs:
		var castling_windrose_offset = FrameworkSettings.WINDROSE_OFFSETS[castling_offset_index]
		var last_tile_in_sequence = tile.windrose_to_sequence[castling_windrose_offset].back()
		
		if last_tile_in_sequence.piece != null:
			var castling_rook = last_tile_in_sequence.piece
			
			if castling_rook.is_inactive:
				var target_tile = tile.windrose_to_sequence[castling_windrose_offset][1]
				add_move(target_tile, null, castling_rook)
				pass
	
func geterate_pawn_moves() -> void:
	geterate_pawn_advance_moves()
	geterate_pawn_capture_moves()
	geterate_pawn_passant_capture_move()
	
func geterate_pawn_advance_moves() -> void:
	var direction_index = 0
	var step_count = 1
	
	if board.buttom_color == template.color:
		direction_index = 4
	
	match template.color:
		FrameworkSettings.PieceColor.WHITE:
			if tile.coord.y == 6:
				step_count = 2
		FrameworkSettings.PieceColor.BLACK:
			if tile.coord.y == 1:
				step_count = 2
	
	var direction = FrameworkSettings.WINDROSE_DIRECTIONS[direction_index]
	
	for _i in step_count:
		var coord = tile.coord + direction * (_i + 1)
		var target_tile = board.get_tile_based_on_coord(coord)
	
		if target_tile:
			if target_tile.piece == null:
				add_move(target_tile)
	
func geterate_pawn_capture_moves() -> void:
	var direction_indexs = []
	
	match template.color:
		FrameworkSettings.PieceColor.WHITE:
			direction_indexs = [1, 7]
		FrameworkSettings.PieceColor.BLACK:
			direction_indexs = [3, 5]
	
	for direction_index in direction_indexs:
		var direction = FrameworkSettings.WINDROSE_DIRECTIONS[direction_index]
		var coord = tile.coord + direction
		var target_tile = board.get_tile_based_on_coord(coord)
	
		if target_tile:
			if target_tile.piece != null:
				if target_tile.piece.template.color != template.color:
					add_move(target_tile)
	
func geterate_pawn_passant_capture_move() -> void:
	if board.notation.moves.is_empty(): return
	var last_move = board.notation.moves.back()
	if last_move.piece.template.type != FrameworkSettings.PieceType.PAWN: return
	
	var passant_direction_indexs = [2, 6]
	var capture_direction_indexs = []
	
	match template.color:
		FrameworkSettings.PieceColor.WHITE:
			capture_direction_indexs = [1, 7]
		FrameworkSettings.PieceColor.BLACK:
			capture_direction_indexs = [3, 5]
	
	for _i in passant_direction_indexs.size():
		var passant_direction_index = passant_direction_indexs[_i]
		var passant_direction = FrameworkSettings.WINDROSE_DIRECTIONS[passant_direction_index]
		var passant_coord = tile.coord + passant_direction
		var passant_tile = board.get_tile_based_on_coord(passant_coord)
	
		if passant_tile:
			if passant_tile.piece != null:
				if passant_tile.piece == last_move.piece:
					var capture_direction_index = capture_direction_indexs[_i]
					var capture_direction = FrameworkSettings.WINDROSE_DIRECTIONS[capture_direction_index]
					var capture_coord = tile.coord + capture_direction
					var capture_tile = board.get_tile_based_on_coord(capture_coord)
					add_move(capture_tile, passant_tile.piece)
					return
	
func geterate_knight_moves() -> void:
	for direction in FrameworkSettings.KNIGHT_MOVES:
		var coord = tile.coord + direction
		var target_tile = board.get_tile_based_on_coord(coord)
		
		if target_tile != null:
			if target_tile.piece != null:
				if target_tile.piece.template.color != template.color:
					add_move(target_tile)
			else:
				add_move(target_tile)
	
func geterate_sliding_moves() -> void:
	var start_offset_index: int = 0
	var end_offset_index: int = FrameworkSettings.WINDROSE_OFFSETS.size()
	var offset_index_step: int = 1
	
	if template.type == FrameworkSettings.PieceType.BISHOP:
		start_offset_index = 1
		offset_index_step = 2
	
	if template.type == FrameworkSettings.PieceType.ROOK:
		offset_index_step = 2
	
	for offset_index in range(start_offset_index, end_offset_index, offset_index_step):
		var windrose_offset = FrameworkSettings.WINDROSE_OFFSETS[offset_index]
		
		for tile_in_sequence in tile.windrose_to_sequence[windrose_offset]:
			if tile_in_sequence.piece == null:
				add_move(tile_in_sequence)
				
				if template.type == FrameworkSettings.PieceType.KING:
					break 
				else:
					continue
			
			#blocked by friendly Piece, so cant' move any further in this direction
			if tile_in_sequence.piece.template.color == template.color:
				break
			
			add_move(tile_in_sequence)
			
			#can't move any further in this direction after capturing opponen's piece
			if tile_in_sequence.piece.template.color != template.color:
				break
	
func add_move(target_tile_: TileResource, captured_piece_: PieceResource = null, castling_rook_: PieceResource = null) -> void:
	if captured_piece_ == null and target_tile_.piece != self:
		captured_piece_ = target_tile_.piece
	
	var move = MoveResource.new(self, tile, target_tile_, captured_piece_, castling_rook_)
	moves.append(move)
	
func is_valid_tile(tile_: TileResource) -> bool:
	for move in moves:
		if move.end_tile == tile_:
			return true
	
	return false
	
func is_same_color(piece_resource_: PieceResource) -> bool:
	return piece_resource_.template.color == template.color
	
func get_move(target_tile_: TileResource) -> Variant:
	for move in moves:
		if move.end_tile == target_tile_:
			return move
	
	return null
