using HTTP, JSON

# login
url = "https://api.quantum-computing.ibm.com/api/users/loginWithToken"
req = Dict("apiToken" => "44f091b1c8eb68ef037aa89699446597eaa2bc7fbb2805779b37d6dc3cf4507aaef5f499265af6aee2a327d90ffac2bcf112d5336b52d236a07d4f3cb25f5c33")
headers = (("content-type", "application/json"), ("Accept", "application/json"))
response = HTTP.post(url, headers, JSON.json(req))
response_json = String(response.body)
response_parsed = JSON.parse(response_json)
id = response_parsed["id"]


# get backends info
url_back = "https://api.quantum-computing.ibm.com/api/Backends?access_token=$(id)"
response_back = HTTP.get(url_back)
response_back_json = String(response_back.body)
response_back_parsed = JSON.parse(response_back_json)
id_back = [i["id"] for i in response_back_parsed]


# calibration info for a given processor [WIP] 
url_back_calib = "https://api.quantum-computing.ibm.com/api/Backends/$(id_back[1])/calibration?access_token=$(id)"
response_back_calib = HTTP.get(url_back_calib)
response_back_json_calib = String(response_back.body)
response_back_parsed_calib = JSON.parse(response_back_json)

