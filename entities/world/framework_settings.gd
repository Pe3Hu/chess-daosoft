extends Node



const BOARD_SIZE: Vector2i = Vector2i(8, 8)
const TILE_SIZE: Vector2 = Vector2(32, 32)
const AXIS_OFFSET: Vector2 = Vector2(16, 16)

#"rnbkqbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBKQBNR"
#"RNBKQBNR/PPPPPPPP/8/8/8/8/pppppppp/rnbkqbnr"
const START_FEN: String = "R2K3R/8/8/8/8/8/8/r2k3r"# w KQkq - 0 1"

const AXIS_X: Array[String] = ["a","b","c","d","e","f","g","h"]
const AXIS_Y: Array[String] = ["1","2","3","4","5","6","7","8"]

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

const KNIGHT_MOVES = [
	Vector2i(-1,-2),
	Vector2i( 1,-2),
	Vector2i( 2,-1),
	Vector2i( 2, 1),
	Vector2i( 1, 2),
	Vector2i(-1, 2),
	Vector2i(-2, 1),
	Vector2i(-2,-1)
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

enum MoveType {
	FREE = 0,
	CAPTURE = 1,
	PASSANT = 2,
	CHECK = 3,
	CHECKMATE = 4,
	DRAW = 5,
	PROMOTION = 6,
	CASTLING = 7
}

var squre_to_direction
var symbol_to_type: Dictionary
var move_to_symbol: Dictionary


func _init() -> void:
	init_symbol_to_type()
	init_move_to_symbol()
	
func init_symbol_to_type() -> void:
	symbol_to_type["k"] = PieceType.KING#"king"
	symbol_to_type["p"] = PieceType.PAWN#""pawn"
	symbol_to_type["n"] = PieceType.KNIGHT#""knight"
	symbol_to_type["b"] = PieceType.BISHOP#""bishop"
	symbol_to_type["r"] = PieceType.ROOK#""rook"
	symbol_to_type["q"] = PieceType.QUEEN#""queen"
	
func init_move_to_symbol() -> void:
	move_to_symbol[MoveType.FREE] = "-" 
	move_to_symbol[MoveType.CAPTURE] = "x" 
	move_to_symbol[MoveType.PASSANT] = "e.p." 
	move_to_symbol[MoveType.CHECK] = "+" 
	move_to_symbol[MoveType.CHECKMATE] = "#" 
	move_to_symbol[MoveType.DRAW] = "=" 
	move_to_symbol[MoveType.PROMOTION] = "=" 
	move_to_symbol[MoveType.CASTLING] = "O-O" 
	
func check_is_tile_id_is_valid(tile_id_: int) -> bool:
	return tile_id_ >= 0 and tile_id_ < BOARD_SIZE.x * BOARD_SIZE.y
	
func check_is_tile_id_is_on_borad_edge(tile_id_: int) -> bool:
	var x = tile_id_ % BOARD_SIZE.x
	var y = tile_id_ * (1.0 / BOARD_SIZE.x)
	return x == 0 or y == 0 or x == BOARD_SIZE.x - 1 or y == BOARD_SIZE.y - 1
	
func check_is_tile_coord_is_valid(tile_coord_: Vector2i) -> bool:
	return tile_coord_.x >= 0 and tile_coord_.y >= 0 and tile_coord_.x < BOARD_SIZE.x and tile_coord_.y < BOARD_SIZE.y
