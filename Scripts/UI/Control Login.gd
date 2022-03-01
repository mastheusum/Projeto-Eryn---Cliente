extends Control

func _on_Control_Login_visibility_changed():
	$Username.text = ''
	$Password.text = ''


func _on_ButtonLogin_pressed():
	var can_login = true
	var error = "Creating Account.\nPlease Wait..."
	
	var username : String = $Username.text
	var password : String = $Password.text
	
	var pool_username = username.split(' ')
	var tmp_username = pool_username.join('')
	
	if username != tmp_username:
		can_login = false
	elif username.length() < 6 or password.length() < 6:
		can_login = false
	
	if can_login:
		username = username.to_upper()
		password = password.sha256_text()
		
		configure_panel_wait("Creating Account.\nPlease Wait...", 2.0)
		
		ConnectionManager.rpc_id(1, 'request_login', username, password)
	else:
		configure_panel_wait("Invalid Username or Password", 2.0)

func _on_ButtonCreate_Account_pressed():
	get_node('/root/Lobby').login_to_create_new_account(true)

func _on_PanelWait_timeout():
	$PanelWait.visible = false
	# enable the buttons to allow requests
	$ButtonLogin.disabled = false
	$"ButtonCreate Account".disabled = false

func configure_panel_wait(message : String, wait_time : float):
	# disable the buttons to prevent multiple requests
	$ButtonLogin.disabled = true
	$"ButtonCreate Account".disabled = true
	
	$PanelWait.visible = true
	
	$PanelWait/Label.text = message
	$PanelWait/Timer.start(wait_time)
