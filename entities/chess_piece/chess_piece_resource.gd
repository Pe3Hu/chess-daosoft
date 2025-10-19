class_name ChessPieceResource
extends Resource


var chess_board: ChessBoardResource
var template: ChessPieceTemplateResource
var chess_tile: ChessTileResource

var chess_moves: Array[ChessMoveResource]


func _init(chess_board_: ChessBoardResource, template_: ChessPieceTemplateResource, chess_tile_: ChessTileResource) -> void:
	chess_board = chess_board_
	template = template_
	chess_tile_.place_chess_piece(self)
	
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
	chess_moves.clear()
	
	if template.type == FrameworkSettings.PieceType.PAWN:
		geterate_pawn_moves()
		return
	if template.type == FrameworkSettings.PieceType.KNIGHT:
		geterate_knight_moves()
		return
	
	geterate_sliding_moves()
	
func geterate_pawn_moves() -> void:
	var direction_index = 0
	
	if chess_board.buttom_color != template.color:
		direction_index = 4
	
	var direction = FrameworkSettings.WINDROSE_DIRECTIONS[direction_index]
	var coord = chess_tile.coord + direction
	var target_chess_tile = chess_board.get_tile_based_on_coord(coord)
	
	if target_chess_tile:
		if target_chess_tile.chess_piece == null:
			add_move(target_chess_tile)
	
func geterate_knight_moves() -> void:
	for direction in FrameworkSettings.KNIGHT_MOVES:
		var coord = chess_tile.coord + direction
		var target_chess_tile = chess_board.get_tile_based_on_coord(coord)
		
		if target_chess_tile != null:
			if target_chess_tile.chess_piece != null:
				if target_chess_tile.chess_piece.template.color != template.color:
					add_move(target_chess_tile)
			else:
				add_move(target_chess_tile)
	
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
		#print([start_offset_index, end_offset_index, offset_index_step, windrose_offset, chess_tile.windrose_to_sequence[windrose_offset].size()])
		
		for chess_tile_in_sequence in chess_tile.windrose_to_sequence[windrose_offset]:
			if chess_tile_in_sequence.chess_piece == null:
				add_move(chess_tile_in_sequence)
				
				if template.type == FrameworkSettings.PieceType.KING:
					break 
				else:
					continue
			
			#blocked by friendly ChessPiece, so cant' move any further in this direction
			if chess_tile_in_sequence.chess_piece.template.color == template.color:
				#print(windrose_offset, "same color")
				break
			
			add_move(chess_tile_in_sequence)
			
			#can't move any further in this direction after capturing opponen's piece
			if chess_tile_in_sequence.chess_piece.template.color != template.color:
				#print(windrose_offset, "diffrent color")
				break
	
func add_move(target_chess_tile_: ChessTileResource) -> void:
	var chess_move = ChessMoveResource.new(self, chess_tile, target_chess_tile_)
	#print(move.end_chess_tile.id)
	chess_moves.append(chess_move)
	
func is_valid_chess_tile(chess_tile_: ChessTileResource) -> bool:
	for chess_move in chess_moves:
		if chess_move.end_chess_tile == chess_tile_:
			return true
	
	return false
	
func is_same_color(chess_piece_resource_: ChessPieceResource) -> bool:
	return chess_piece_resource_.template.color == template.color
	
func get_chess_move(target_chess_tile_: ChessTileResource) -> Variant:
	for chess_move in chess_moves:
		if chess_move.end_chess_tile == target_chess_tile_:
			return chess_move
	
	return null
