extends Node



const DEFAULT_BOARD_SIZE: Vector2i = Vector2i(8, 8)
const TILE_SIZE: Vector2 = Vector2(32, 32)
const AXIS_OFFSET: Vector2 = Vector2(16, 16)

const CLOCK_START_MIN: int = 5
const CLOCK_START_SEC: int = 0

const VOID_CHANCE_TO_STAND: float = 0.05
const VOID_CHANCE_TO_ESCAPE: float = 0.05

const GAMBIT_BOARD_SIZE: Vector2i = Vector2i(9, 9)
const ALTAR_COORD: Vector2i = Vector2i(4, 4)
const SACRIFICE_COUNT_FOR_VICTORY: int = 5

#"r1NK3r/2NP4/3Q4/b/8/8/pppppppp/rnbkqbQr"
#"q1NKQ2r/2PPP3/8/b7/8/8/4p3/4k3" pin
#"RNBQKBNR/PPPPPPPP/8/8/8/8/pppppppp/rnbqkbnr" classic
#"8/8/RNBQKBNR/PPPPPPPP/pppppppp/rnbqkbnr/8/8" void
#"8/8/RNBQKBNR/PPPP2PP/pppp2bp/rnbkq11r/8/8" check
#"RNBQKQBNR/PPPPPPPPP/9/9/9/9/9/ppppppppp/rnbqkqbnr" gambit
#"9/9/RNBQKQBNR/PPPB1BPPP/9/ppppppppp/rnbqkqbnr/9/9" gambit test
#"RNBQKBHR/PPPPPPPP/8/8/7H/6p1/pppppppp/rnbqkbhr" hellhorse king capture and phantom
#"RNBQKBHR/PPPPPPPP/8/8/8/8/pppppppp/rnbqkbhr" hellhorse start
const START_FEN: String = "RNBQKBNR/PPPPPPPP/8/8/8/8/pppppppp/rnbqkbnr"
const START_GAMBIT_FEN: String = "RNBQKQBNR/PPPPPPPPP/9/9/9/9/9/ppppppppp/rnbqkqbnr"
const START_HELLHORSE_FEN: String = "RNBQKBHR/PPPPPPPP/8/8/8/8/pppppppp/rnbqkbhr"

const AXIS_X: Array[String] = ["a","b","c","d","e","f","g","h","i"]
const AXIS_Y: Array[String] = ["1","2","3","4","5","6","7","8","9"]

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

const SLIDE_PIECES = [
	PieceType.BISHOP,
	PieceType.ROOK,
	PieceType.QUEEN
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
	CAPTURE = 3,
	CHECK = 4,
	PIN = 5,
	AlTAR = 6,
}

enum PieceType {
	NONE = 0,
	KING = 1,       # 00001
	PAWN = 2,       # 00010
	KNIGHT = 3,     # 00011
	BISHOP = 4,     # 00100
	ROOK = 5,       # 00101
	QUEEN = 6,      # 00110
	HELLHORSE = 7   # 00111
}

enum PieceColor {
	WHITE = 8,      # 01000
	BLACK = 16      # 10000
}

var PIECE_COLORS = [PieceColor.WHITE, PieceColor.BLACK]

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

enum ModeType {
	CLASSIC = 0,
	FOX = 1,
	VOID = 2,
	HELLHORSE = 3,
	GAMBIT = 4,
	SPY = 5,
}

enum CursorState {
	IDLE = 0,
	SELECT = 1,
	HOLD = 2
}

var BOARD_SIZE: Vector2i = DEFAULT_BOARD_SIZE
var squre_to_direction
var symbol_to_type: Dictionary
var move_to_symbol: Dictionary
var mod_to_fen: Dictionary
var mod_to_board_size: Dictionary


func _init() -> void:
	init_symbol_to_type()
	init_move_to_symbol()
	init_mod_to_fen()
	init_mod_to_board_size()
	
func init_symbol_to_type() -> void:
	symbol_to_type["k"] = PieceType.KING#"king"
	symbol_to_type["p"] = PieceType.PAWN#""pawn"
	symbol_to_type["n"] = PieceType.KNIGHT#""knight"
	symbol_to_type["b"] = PieceType.BISHOP#""bishop"
	symbol_to_type["r"] = PieceType.ROOK#""rook"
	symbol_to_type["q"] = PieceType.QUEEN#""queen"
	symbol_to_type["h"] = PieceType.HELLHORSE#""queen"
	
func init_move_to_symbol() -> void:
	move_to_symbol[MoveType.FREE] = "-" 
	move_to_symbol[MoveType.CAPTURE] = "x" 
	move_to_symbol[MoveType.PASSANT] = "e.p." 
	move_to_symbol[MoveType.CHECK] = "+" 
	move_to_symbol[MoveType.CHECKMATE] = "#" 
	move_to_symbol[MoveType.DRAW] = "=" 
	move_to_symbol[MoveType.PROMOTION] = "=" 
	move_to_symbol[MoveType.CASTLING] = "O-O" 
	
func init_mod_to_fen() -> void:
	mod_to_fen[FrameworkSettings.ModeType.CLASSIC] = START_FEN
	mod_to_fen[FrameworkSettings.ModeType.FOX] = START_FEN
	mod_to_fen[FrameworkSettings.ModeType.VOID] = START_FEN
	mod_to_fen[FrameworkSettings.ModeType.GAMBIT] = START_GAMBIT_FEN
	mod_to_fen[FrameworkSettings.ModeType.HELLHORSE] = START_HELLHORSE_FEN
	
func init_mod_to_board_size() -> void:
	mod_to_board_size[FrameworkSettings.ModeType.CLASSIC] = DEFAULT_BOARD_SIZE
	mod_to_board_size[FrameworkSettings.ModeType.FOX] = DEFAULT_BOARD_SIZE
	mod_to_board_size[FrameworkSettings.ModeType.VOID] = DEFAULT_BOARD_SIZE
	mod_to_board_size[FrameworkSettings.ModeType.GAMBIT] = GAMBIT_BOARD_SIZE
	mod_to_board_size[FrameworkSettings.ModeType.HELLHORSE] = DEFAULT_BOARD_SIZE
	
func check_is_tile_id_is_valid(tile_id_: int) -> bool:
	return tile_id_ >= 0 and tile_id_ < BOARD_SIZE.x * BOARD_SIZE.y
	
func check_is_tile_id_is_on_borad_edge(tile_id_: int) -> bool:
	var x = tile_id_ % BOARD_SIZE.x
	var y = tile_id_ * (1.0 / BOARD_SIZE.x)
	return x == 0 or y == 0 or x == BOARD_SIZE.x - 1 or y == BOARD_SIZE.y - 1
	
func check_is_tile_coord_is_valid(tile_coord_: Vector2i) -> bool:
	return tile_coord_.x >= 0 and tile_coord_.y >= 0 and tile_coord_.x < BOARD_SIZE.x and tile_coord_.y < BOARD_SIZE.y
