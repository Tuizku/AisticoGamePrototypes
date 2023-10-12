extends Control

func change_scene(name):
	if get_tree().change_scene("res://scenes/" + name + ".tscn") != OK: print("scene change failed")

func post_to_subscribe(email: String, list_name: String, url: String):
	if has_node("HTTPRequest"):
		print("Wait before submitting another request.")
		return
   
	var http_request = HTTPRequest.new()
	self.add_child(http_request)
	http_request.connect("request_completed", self, "_on_request_completed")
 
	# Do a POST HTTP Request
	var post_string = "email=" + email + "&list=" + list_name
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	http_request.request(url, headers, false, HTTPClient.METHOD_POST, post_string)

func _on_request_completed(_result, response_code, _headers, _body):
	if response_code == 200:
		print("Successfully subscribed.")
	else:
		print("Failed to subscribe with response code: ", response_code)
   
	# Cleanup
	self.remove_child(get_node("HTTPRequest"))

func _on_LaterButton_pressed():
	change_scene("menu")


func _on_SendButton_pressed():
	var mail = $LineEdit.text
	if mail != "" and "@" in mail:
		post_to_subscribe(mail, "sanapelistä kiinnostuneet", "https://aistico.com/data/sanaemails/append.php")
	else: $LineEdit.text = "sähköposti virheellinen..."
