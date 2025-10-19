class_name ChessBoardResource
extends Resource


var chess_tiles: Array[ChessTileResource]
var coord_to_chess_piece: Dictionary

var focus_chess_tile: ChessTileResource:
	set(value_):
		reset_chess_tile_states()
		focus_chess_tile = value_
		
		if focus_chess_tile != null:
			update_chess_tile_states()
var legal_chess_tiles: Array[ChessTileResource]


func _init() -> void:
	init_chess_tiles()
	#add_piece(0, FrameworkSettings.PieceColor.WHITE | FrameworkSettings.PieceType.BISHOP)
	#add_piece(63, FrameworkSettings.PieceColor.BLACK | FrameworkSettings.PieceType.KING)
	
	load_position_from_fen(FrameworkSettings.START_FEN)
	
func init_chess_tiles() -> void:
	for file in FrameworkSettings.BOARD_SIZE.y:
		for rank in FrameworkSettings.BOARD_SIZE.x:
			var coord = Vector2i(rank, file)
			add_chess_tile(coord)
	
	for chess_tile in chess_tiles:
		chess_tile.find_all_sequences()
	
func get_tile_based_on_coord(coord_: Vector2i) -> Variant:
	if FrameworkSettings.check_is_chess_tile_coord_is_valid(coord_):
		var id = coord_.y * FrameworkSettings.BOARD_SIZE.x + coord_.x
		return chess_tiles[id]
	
	return null
	
func add_chess_tile(coord_: Vector2i) -> void:
	var chess_tile = ChessTileResource.new(self, coord_)
	chess_tiles.append(chess_tile)
	
func load_position_from_fen(fen_: String) -> void:
	var fen_board: String = fen_.split(' ')[0]
	var file: int = 0
	var rank: int = 7
	
	for symbol in fen_board:
		if symbol == "/":
			file = 0
			rank -= 1
		else:
			if symbol.is_valid_int():
				file += int(symbol)
			else:
				var piece_color = FrameworkSettings.PieceColor.BLACK#"black"
				var is_white = symbol.capitalize() == symbol
				if is_white:
					piece_color = FrameworkSettings.PieceColor.WHITE#"white"
				
				var piece_type =  FrameworkSettings.symbol_to_type[symbol.to_lower()]
				var coord_index = rank * FrameworkSettings.BOARD_SIZE.x + file
				var piece_index = piece_type | piece_color
				add_piece(coord_index, piece_index)
				file += 1
	
func add_piece(coord_id_: int, piece_id_: int) -> void:
	coord_to_chess_piece[coord_id_] = ChessPieceResource.new(self, piece_id_, coord_id_)
	
func update_chess_tile_states() -> void:
	focus_chess_tile.current_state = FrameworkSettings.TileState.CURRENT
	
	for windrose_offset in focus_chess_tile.windrose_to_sequence:
		for sequence_chess_tile in focus_chess_tile.windrose_to_sequence[windrose_offset]:
			sequence_chess_tile.current_state = FrameworkSettings.TileState.NEXT
			legal_chess_tiles.append(sequence_chess_tile)
	
func reset_chess_tile_states() -> void:
	if focus_chess_tile == null: return
	focus_chess_tile.current_state = FrameworkSettings.TileState.NONE
	
	for legal_chess_tile in legal_chess_tiles:
		legal_chess_tile.current_state = FrameworkSettings.TileState.NEXT
	
	legal_chess_tiles.clear()
