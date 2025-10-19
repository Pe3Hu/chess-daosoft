extends Node



const BOARD_SIZE: Vector2i = Vector2i(8, 8)
const TILE_SIZE: Vector2 = Vector2(32, 32)

const START_FEN: String = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"# w KQkq - 0 1"

const WINDROSE_OFFSETS = [
	WindroseOffset.N,
	WindroseOffset.NE,
	WindroseOffset.E,
	WindroseOffset.SE,
	WindroseOffset.S,
	WindroseOffset.SW,
	WindroseOffset.W,
	WindroseOffset.NW
]

const WINDROSE_DIRECTIONS = [
	Vector2i( 0,-1),
	Vector2i( 1, -1),
	Vector2i( 1, 0),
	Vector2i( 1, 1),
	Vector2i( 0, 1),
	Vector2i(-1, 1),
	Vector2i(-1, 0),
	Vector2i(-1,-1)
]

enum WindroseOffset {
	N = -8,
	NE = -7,
	E = 1,
	SE =- -9,
	S = 8,
	SW = 7,
	W = -1,
	NW = -9
}

enum TileState {
	NONE = 0,
	CURRENT = 1,
	NEXT = 2,
}

enum PieceType {
	NONE = 0,
	KING = 1,       # 00001
	PAWN = 2,       # 00010
	KNIGHT = 3,     # 00011
	BISHOP = 4,     # 00100
	ROOK = 5,       # 00101
	QUEEN = 6       # 00110
}

enum PieceColor {
	WHITE = 8,      # 01000
	BLACK = 16      # 10000
}

var squre_to_direction
var symbol_to_type: Dictionary


func _init() -> void:
	init_symbol_to_type()
	
func init_symbol_to_type() -> void:
	symbol_to_type["k"] = FrameworkSettings.PieceType.KING#"king"
	symbol_to_type["p"] = FrameworkSettings.PieceType.PAWN#""pawn"
	symbol_to_type["n"] = FrameworkSettings.PieceType.KNIGHT#""knight"
	symbol_to_type["b"] = FrameworkSettings.PieceType.BISHOP#""bishop"
	symbol_to_type["r"] = FrameworkSettings.PieceType.ROOK#""rook"
	symbol_to_type["q"] = FrameworkSettings.PieceType.QUEEN#""queen"
	
func check_is_chess_tile_id_is_valid(chess_tile_id_: int) -> bool:
	return chess_tile_id_ >= 0 and chess_tile_id_ < BOARD_SIZE.x * BOARD_SIZE.y
	
func check_is_chess_tile_id_is_on_borad_edge(chess_tile_id_: int) -> bool:
	var x = chess_tile_id_ % BOARD_SIZE.x
	var y = chess_tile_id_ / BOARD_SIZE.x
	return x == 0 or y == 0 or x == BOARD_SIZE.x - 1 or y == BOARD_SIZE.y - 1
	
func check_is_chess_tile_coord_is_valid(chess_tile_coord_: Vector2i) -> bool:
	return chess_tile_coord_.x >= 0 and chess_tile_coord_.y >= 0 and chess_tile_coord_.x < BOARD_SIZE.x and chess_tile_coord_.y < BOARD_SIZE.y
	
#func check_chess_tile_on_same_axis(chess_tiles_: Array) -> bool:
	##var x = chess_tiles_.front() % BOARD_SIZE.x
	##var y = chess_tiles_.front() / BOARD_SIZE.x
	##var a_coord = Vector2i(x, y)
	##x = chess_tiles_.back() % BOARD_SIZE.x
	##y = chess_tiles_.back() / BOARD_SIZE.x
	##var b_coord = Vector2i(x, y)
	#var a_tile = chess_tiles_.front()
	#var b_tile = chess_tiles_.back()
	#return a_tile.coord.x == b_tile.coord.x or a_tile.coord.y == b_tile.coord.y
