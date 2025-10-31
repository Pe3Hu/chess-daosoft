class_name GameResource
extends Resource


var notation: NotationResource = NotationResource.new(self)
var referee: RefereeResource = RefereeResource.new(self)
var board: BoardResource = BoardResource.new(self)


func _init() -> void:
	for player in referee.players:
		player.board = board
	
	before_first_move()
	
	#var result = move_generation_test(2)
	#print(result)
	
func move_generation_test(depth_: int) -> int:
	if depth_ == 0: return 1
	var count_positiions = 0
	referee.active_player.generate_legal_moves()
	var moves = referee.active_player.legal_moves
	moves.sort_custom(func (a, b): return a.end_tile.id < b.end_tile.id)
	
	for move in moves:
		board.make_move(move)
		#var _count_positiions = move_generation_test(depth_ - 1)
		#count_positiions += _count_positiions
		#if _count_positiions > 1:
		#	print([move.piece.template.type, move.start_tile.id, move.end_tile.id, _count_positiions])
		count_positiions += move_generation_test(depth_ - 1)
		board.unmake_move(move)
	
	return count_positiions
	
func before_first_move() -> void:
	var black_player = referee.color_to_player[FrameworkSettings.PieceColor.BLACK]
	black_player.find_threat_moves()
	var white_player = referee.color_to_player[FrameworkSettings.PieceColor.WHITE]
	white_player.generate_legal_moves()
