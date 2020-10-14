using HTTP, JSON
using Yao, YaoBlocks
const headers = (("content-type", "application/json"), ("Accept", "application/json"))

struct IBMQUser #store other info here
    id::String
end

struct Qobj
    data::Dict{String, Any}
end

struct IBMQReg 
    id::String
    device::String
    uploadurl::String
    jobid::String     
end

"""
Login method
"""
function authenticate(token::String = "") # todo : save the token
    if length(token) == 0
        println("IBM QE token > ")
        token = readline()
    end
    conf = (readtimeout = 1,     # todo handle timeouts better
        pipeline_limit = 4,
        retry = false,
        redirect = false)

    url = "https://api.quantum-computing.ibm.com/api/users/loginWithToken"
    req = Dict("apiToken" => token)
    response = HTTP.post(url, headers, JSON.json(req); conf...)
    
    response_json = String(response.body)
    response_parsed = JSON.parse(response_json)
    if response.status == 200
        println("Login Successful")
    end
    IBMQUser(response_parsed["id"])
end

"""
Get backends info
"""
function get_backends(user::IBMQUser)
    id = user.id
    url_back = "https://api.quantum-computing.ibm.com/api/Network/ibm-q/Groups/open/Projects/main/devices/v/1?access_token=$(id)"
    response_back = HTTP.get(url_back)
    response_back_json = String(response_back.body)
    response_back_parsed = JSON.parse(response_back_json)
    device_info = response_back_parsed[1]
    id_back = [i["backend_name"] for i in response_back_parsed]
end

function run(user::IBMQUser, qobj::Qobj, device::String)
    url = "https://api.quantum-computing.ibm.com/api/Network/ibm-q/Groups/open/Projects/main/Jobs?access_token=$(id)" #user.id

    req = Dict("backend" => Dict("name" => device), "allowObjectStorage" => true, "shareLevel"=> "none")
    request = HTTP.post(url , headers, JSON.json(req))
    response_json = String(request.body)
    response_parsed = JSON.parse(response_json)
    
    objectinfo = response_parsed["objectStorageInfo"]
    upload_url = objectinfo["uploadUrl"]
    jobid = response_parsed["id"]

    json = JSON.json(qobj.data)
    ckt_upload = HTTP.put(upload_url, [], json) 

    #if 200
    # Notify the backend that the job has been uploaded
    url = "https://api.quantum-computing.ibm.com/api/Network/ibm-q/Groups/open/Projects/main/Jobs/$(jobid)/jobDataUploaded?access_token=$(id)"
    json_step4 ="""{
                "data": "none",
                "json": "none"
            }"""
    request = HTTP.post(url, headers, json_step4)
    return job_id
end

function status()
    url = "https://api.quantum-computing.ibm.com/api/Network/ibm-q/Groups/open/Projects/main/Jobs/$(jobid)?access_token=$(id)"
    result = HTTP.get(url)
    response_json = String(result.body)
    response_parsed = JSON.parse(response_json)
    return response_parsed["status"]
end

# get result
url = "https://api.quantum-computing.ibm.com/api/Network/ibm-q/Groups/open/Projects/main/Jobs/$(jobid)/resultDownloadUrl?access_token=$(id)"
result = HTTP.get(url)
response_json = String(result.body)
response_parsed = JSON.parse(response_json)
downloadUrl = response_parsed["url"]
final_res = HTTP.get(downloadUrl)
response_json = String(final_res.body)
response_parsed = JSON.parse(response_json)
res = response_parsed["results"]


# STEP8: Confirm the data was downloaded
url = "https://api.quantum-computing.ibm.com/api/Network/ibm-q/Groups/open/Projects/main/Jobs/$(jobid)/resultDownloaded?access_token=$(id)"
json_step8 = """{
    "data": "none",
    "json": "none"
}"""
result = HTTP.post(url, headers, json_step8)





















# # check if device is online
# function is_online(id_back::Array, device_name::String)
#     return device in id_back 
# end

# #  info (dict): dictionary sent by the backend containing the code to run 
# # or we can have it has the number of qubits in our circuit
# function can_run_experiment(info::Dict, response_back_parsed, device::Dict)
#     info['nq'] <= device["n_qubits"] ? true : false
# end
# json = """{
#     "qobj_id": "exp123_072018",
#     "schema_version": "1.0.0",
#     "type": "QASM",
#     "header": {
#         "description": "Set of Experiments 1",
#         "backend_name": "ibmq_qasm_simulator"},
#     "config": {
#         "shots": 1024,
#         "memory_slots": 1,
#         "init_qubits": true
#         },
#     "experiments": [
#         {
#         "header": {
#             "memory_slots": 1,
#             "n_qubits": 2,
#             "clbit_labels": [["c1", 0]],
#             "qubit_labels": [null,["q", 0],["q",1]]
#             },
#         "config": {},
#         "instructions": [
#             {"name": "h", "qubits": [1]},
#             {"name": "id", "qubits": [2]},
#             {"name": "s", "qubits": [1]}
#             ]
#         }
#         ]    
# }"""
