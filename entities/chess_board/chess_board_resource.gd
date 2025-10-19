class_name ChessBoardResource
extends Resource


var chess_notation: ChessNotationResource = ChessNotationResource.new()
var chess_tiles: Array[ChessTileResource]
var legal_chess_tiles: Array[ChessTileResource]
var focus_chess_tile: ChessTileResource:
	set(value_):
		reset_chess_tile_states()
		focus_chess_tile = value_
		
		if focus_chess_tile != null:
			update_chess_tile_states()

var chess_pieces: Array[ChessPieceResource]
var captured_templates: Dictionary


var buttom_color: FrameworkSettings.PieceColor = FrameworkSettings.PieceColor.BLACK


func _init() -> void:
	init_chess_tiles()
	#add_piece(FrameworkSettings.PieceColor.BLACK | FrameworkSettings.PieceType.BISHOP, 25)
	#focus_chess_tile = chess_tiles[25]
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
				var chess_tile_index = rank * FrameworkSettings.BOARD_SIZE.x + file
				var template_id = piece_type | piece_color
				add_piece(template_id, chess_tile_index)
				file += 1
	
func add_piece(template_id_: int, chess_tile_index_: int,) -> void:
	var template = load("res://entities/chess_piece/templates/" + str(template_id_) + ".tres")
	var chess_tile = chess_tiles[chess_tile_index_]
	var chess_piece = ChessPieceResource.new(self, template, chess_tile)
	chess_pieces.append(chess_piece)
	
func update_chess_tile_states() -> void:
	focus_chess_tile.current_state = FrameworkSettings.TileState.CURRENT
	focus_chess_tile.chess_piece.geterate_legal_moves()
	
	for chess_move in focus_chess_tile.chess_piece.chess_moves:
		chess_move.end_chess_tile.current_state = FrameworkSettings.TileState.NEXT
		legal_chess_tiles.append(chess_move.end_chess_tile)
	
func reset_chess_tile_states() -> void:
	if focus_chess_tile == null: return
	focus_chess_tile.current_state = FrameworkSettings.TileState.NONE
	
	for legal_chess_tile in legal_chess_tiles:
		legal_chess_tile.current_state = FrameworkSettings.TileState.NEXT
	
	legal_chess_tiles.clear()
	
func capture_chess_piece(chess_piece_: ChessPieceResource) -> void:
	if !captured_templates.has(chess_piece_.template):
		captured_templates[chess_piece_] = 0
	
	captured_templates[chess_piece_] += 1
	chess_piece_.chess_tile.chess_piece = null
	chess_pieces.erase(chess_piece_)
