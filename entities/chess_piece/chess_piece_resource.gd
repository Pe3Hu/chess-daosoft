class_name ChessPieceResource
extends Resource


var chess_board: ChessBoardResource
var chess_tile: ChessTileResource
var is_on_board: bool = true

var id: int:
	set(value_):
		id = value_


func _init(chess_board_: ChessBoardResource, id_: int, coord_id_: int) -> void:
	chess_board = chess_board_
	id = id_
	chess_board.chess_tiles[coord_id_].place_chess_piece(self)
	
func get_type() -> String:
	var type_id = id & 7
	match type_id:
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
	var color_id = id & 24
	match color_id:
		FrameworkSettings.PieceColor.WHITE:
			return "white"
		FrameworkSettings.PieceColor.BLACK:
			return "black"
	
	return ""
	
#func get_vector() -> Vector2:
	#var coord = Vector2(coord_id % FrameworkSettings.BOARD_SIZE.x, coord_id / FrameworkSettings.BOARD_SIZE.x)
	#return FrameworkSettings.TILE_SIZE * Vector2(coord)
	
func geterate_sliding_moves() -> void:
	#for direction_index in a:
	pass
	
func is_valid_chess_tile(_chess_tile_: ChessTileResource) -> bool:
	return true
