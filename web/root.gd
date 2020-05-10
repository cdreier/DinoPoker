extends Node2D

var client = WebSocketClient.new()

func getServer():
	var server = "ws://127.0.0.1:5000"
	if OS.has_feature('JavaScript'):
		var tmp = JavaScript.eval("""
			const urlParams = new URLSearchParams(window.location.search);
			urlParams.get('server');
		""")
		if tmp != "":
			server = tmp
	return server

func _ready():

	var url = getServer() 
	print(url)
	var error = client.connect_to_url(url, PoolStringArray(), true);
	get_tree().set_network_peer(client);
	
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _connected_ok():
	print("connect OK")
	
func _connected_fail():
	print("connect failed")
	
func _server_disconnected():
	print("disconnected")
	
remote func connected():
	var selfPeerID = get_tree().get_network_unique_id()
	var my_player = preload("res://player.tscn").instance()
	my_player.set_name(str(selfPeerID))
	my_player.set_network_master(selfPeerID)
	my_player.playerName = $JoinPanel/LineEdit.text
	get_tree().get_root().add_child(my_player)

puppet func spawn_player(id, name):
	if id == get_tree().get_network_unique_id():
		return
	var player = preload("res://player.tscn").instance()
	player.set_name(str(id))
	player.set_network_master(id)
	player.playerName = name
	get_tree().get_root().add_child(player)
	
puppet func remove_player(id):
	var toRemove = get_tree().get_root().get_node(str(id))
	if toRemove != null:
		toRemove.queue_free()
	
func _on_JoinButton_pressed():
	var name = $JoinPanel/LineEdit.text
	rpc_id(1, "registerClient", name)
	$JoinPanel.hide()


func _on_declare_king_body_entered(body):
	if body is KinematicBody2D && body.has_method("isSelf") && body.isSelf():
		$AnnouncementPanel.show()

func _on_declare_king_body_exited(body):
	if body is KinematicBody2D && body.has_method("isSelf") && body.isSelf():
		$AnnouncementPanel.hide()

func _on_AnnouncementText_text_changed():
	rpc_id(1, "setAnnouncement", $AnnouncementPanel/AnnouncementText.text)

remote func setAnnouncement(txt):
	$world/Announcement.text = txt

func _on_CollissionButton_toggled(button_pressed):
	rpc_id(1, "setCollision", button_pressed)
	
remote func setCollision(active):
	$AnnouncementPanel/CollisionButton.pressed = active
	pass

func _process(delta):
	if (client.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED ||
		client.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTING):
		client.poll();
