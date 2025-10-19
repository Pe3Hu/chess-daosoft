class_name ChessNotationResource
extends Resource


var chess_board: ChessBoardResource
var chess_moves: Array[ChessMoveResource]


func record_chess_move(chess_move_: ChessMoveResource) -> void:
	chess_moves.append(chess_move_)
	
