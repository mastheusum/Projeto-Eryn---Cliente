extends Node

var account_id : int = -1
var token : String = ""
var signed_in : bool = false

func set_account_logged(account_id : int, token : String):
	self.account_id = account_id
	if self.account_id != -1:
		self.token = token
		get_node("/root/Lobby").login_to_character_list(true)

func logout():
	account_id = -1
	signed_in = false
	ConnectionManager.rpc_id(1, 'request_logout', token)

func exit_game():
	signed_in = false
	get_node('/root/Lobby').lobby_to_game(false)
	get_node('/root/Harbor').remove_all()
	
	ConnectionManager.rpc_id(
		1, 'request_sign_out_character', token
	)
