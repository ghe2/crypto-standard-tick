# This file demonstrates connecting to the CTP via websockets in Python 3
import websocket, json

# Define the port of the CTP
socket = "ws://localhost:5110"

# Function to run upon opening connection (subscription information)
def on_open(ws):
	print("opened")
	auth_data = {"type":"sub","tables":["trade","vwap"],"syms":"BTCUSD"}
	ws.send(json.dumps(auth_data))

# Upon receiving a message simply print - further data manipulation can be added as desired
def on_message(ws, message):
	data = json.loads(message)
	print(data)

# Connect to the websocket
ws = websocket.WebSocketApp(socket, on_open=on_open, on_message=on_message)
# Keep open the subscription
ws.run_forever()