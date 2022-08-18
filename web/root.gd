extends Node2D

var client = WebSocketClient.new()

remote var playerCount = 0
remote var activeBaseCount = 0
const brutalism_code = "idkfa"

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
	my_player.brutalism = $world/Announcement.text == brutalism_code
	get_tree().get_root().add_child(my_player)
#	debug
	var gun = my_player.get_node("gun")
	gun.connect("fire_bullet", self, "request_bullet_spawn")

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
	var id = get_tree().get_network_unique_id()
	var player = get_tree().get_root().get_node(str(id))
	if player != null:
		player.brutalism = txt == brutalism_code
		

func _on_CollissionButton_toggled(button_pressed):
	rpc_id(1, "setCollision", button_pressed)
	
remote func setCollision(active):
	$AnnouncementPanel/CollisionButton.pressed = active

remote func playerCountChanged(playerCount):
	$AnnouncementPanel/PlayerLabel/players.text = str(playerCount)
	
remote func activeBaseCountChanged(activeOnBase):
	$AnnouncementPanel/PlayerLabel/active.text = str(activeOnBase)
	
# BULLET HANDLING
var bulletClass = preload("res://bullet.tscn")

func request_bullet_spawn(pos, flip):
	rpc_id(1, "spawnBullet", pos, flip)

remotesync func spawn_bullet(pos, flip):
	var b = bulletClass.instance()
	b.position = pos
	if flip:
		b.position.x -= 20
	else:
		b.position.x += 20
	b.flipped = flip
	get_tree().get_root().add_child(b)

func _process(delta):
	if (client.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED ||
		client.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTING):
		client.poll();
