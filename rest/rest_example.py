import requests, json

response = requests.get('http://localhost:5005/getData') # Sending get request
data = response.json()  # Parsing in data
print(data) # Printing data as example, more complex aggregations can be done after request