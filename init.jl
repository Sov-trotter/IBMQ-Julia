using HTTP, JSON
const headers = (("content-type", "application/json"), ("Accept", "application/json"))

struct IBMQUser #store other info here
    id::String
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
    return IBMQUser(response_parsed["id"])
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

function run(user::IBMQUser, qobj::Dict, device::String)
    url = "https://api.quantum-computing.ibm.com/api/Network/ibm-q/Groups/open/Projects/main/Jobs?access_token=$(id)"

    req = Dict("backend" => Dict("name" => device), "allowObjectStorage" => true, "shareLevel"=> "none")
    request = HTTP.post(url , headers, JSON.json(req))
    response_json = String(request.body)
    response_parsed = JSON.parse(response_json)
    
    objectinfo = response_parsed["objectStorageInfo"]
    upload_url = objectinfo["uploadUrl"]
    job_id = response_parsed["id"]

    ckt_upload = HTTP.put(upload_url, [], json) 
    return job_id
end

# Notify the backend that the job has been uploaded
url = "https://api.quantum-computing.ibm.com/api/Network/ibm-q/Groups/open/Projects/main/Jobs/$(job_id)/jobDataUploaded?access_token=$(id)"
json_step4 ="""{
            "data": "none",
            "json": "none"
        }"""
request = HTTP.post(url, headers, json_step4)




# get result
url = "https://api.quantum-computing.ibm.com/api/Network/ibm-q/Groups/open/Projects/main/Jobs/$(job_id)?access_token=$(id)"
result = HTTP.get(url)
response_json = String(result.body)
response_parsed = JSON.parse(response_json)
url = "https://api.quantum-computing.ibm.com/api/Network/ibm-q/Groups/open/Projects/main/Jobs/$(job_id)/resultDownloadUrl?access_token=$(id)"
result = HTTP.get(url)
response_json = String(result.body)
response_parsed = JSON.parse(response_json)
downloadUrl = response_parsed["url"]
final_res = HTTP.get(downloadUrl)
response_json = String(final_res.body)
response_parsed = JSON.parse(response_json)
res = response_parsed["results"]
























# n_classical_reg = info["nq"]
# # hack: easier to restrict labels to measured qubits
# n_qubits = n_classical_reg  # backends[device]['nq']
# instructions = info["json"]
# maxcredit = info["maxCredits"]
# c_label = [["c", i] for i in range(n_classical_reg)]
# q_label = [["q", i] for i in range(n_qubits)]

# # hack: the data value in the json quantum code is a string
# instruction_str = String(instructions).replace('\'', '\"')
# data = '{"qobj_id": "' + str(uuid.uuid4()) + '", '
# data += '"header": {"backend_name": "' + device + '", '
# data += ('"backend_version": "' + self.backends[device]['version']
#          + '"}, ')
# data += '"config": {"shots": ' + str(info['shots']) + ', '
# data += '"max_credits": ' + str(maxcredit) + ', "memory": false, '
# data += ('"parameter_binds": [], "memory_slots": '
#          + str(n_classical_reg))
# data += (', "n_qubits": ' + str(n_qubits)
#          + '}, "schema_version": "1.1.0", ')
# data += '"type": "QASM", "experiments": [{"config": '
# data += '{"n_qubits": ' + str(n_qubits) + ', '
# data += '"memory_slots": ' + str(n_classical_reg) + '}, '
# data += ('"header": {"qubit_labels": '
#          + str(q_label).replace('\'', '\"') + ', ')
# data += '"n_qubits": ' + str(n_classical_reg) + ', '
# data += '"qreg_sizes": [["q", ' + str(n_qubits) + ']], '
# data += '"clbit_labels": ' + str(c_label).replace('\'', '\"') + ', '
# data += '"memory_slots": ' + str(n_classical_reg) + ', '
# data += '"creg_sizes": [["c", ' + str(n_classical_reg) + ']], '
# data += ('"name": "circuit0"}, "instructions": ' + instruction_str
#          + '}]}')



# # check if device is online
# function is_online(id_back::Array, device_name::String)
#     return device in id_back 
# end

# #  info (dict): dictionary sent by the backend containing the code to run 
# # or we can have it has the number of qubits in our circuit
# function can_run_experiment(info::Dict, response_back_parsed, device::Dict)
#     info['nq'] <= device["n_qubits"] ? true : false
# end

# r_json = request.json()
# download_endpoint_url = r_json['objectStorageInfo'][
#     'downloadQObjectUrlEndpoint']
# upload_endpoint_url = r_json['objectStorageInfo'][
#     'uploadQobjectUrlEndpoint']
# upload_url = r_json['objectStorageInfo']['uploadUrl']

# # STEP2: WE USE THE ENDPOINT TO GET THE UPLOT LINK
# json_step2 = {'allow_redirects': True, 'timeout': (5.0, None)}
# request = super(IBMQ, self).get(upload_endpoint_url, **json_step2)
# request.raise_for_status()
# r_json = request.json()

# # STEP3: WE USE THE ENDPOINT TO GET THE UPLOT LINK
# n_classical_reg = info['nq']
# # hack: easier to restrict labels to measured qubits
# n_qubits = n_classical_reg  # self.backends[device]['nq']
# instructions = info['json']
# maxcredit = info['maxCredits']
# c_label = [["c", i] for i in range(n_classical_reg)]
# q_label = [["q", i] for i in range(n_qubits)]

# # hack: the data value in the json quantum code is a string
# instruction_str = str(instructions).replace('\'', '\"')
# data = '{"qobj_id": "' + str(uuid.uuid4()) + '", '
# data += '"header": {"backend_name": "' + device + '", '
# data += ('"backend_version": "' + self.backends[device]['version']
#          + '"}, ')
# data += '"config": {"shots": ' + str(info['shots']) + ', '
# data += '"max_credits": ' + str(maxcredit) + ', "memory": false, '
# data += ('"parameter_binds": [], "memory_slots": '
#          + str(n_classical_reg))
# data += (', "n_qubits": ' + str(n_qubits)
#          + '}, "schema_version": "1.1.0", ')
# data += '"type": "QASM", "experiments": [{"config": '
# data += '{"n_qubits": ' + str(n_qubits) + ', '
# data += '"memory_slots": ' + str(n_classical_reg) + '}, '
# data += ('"header": {"qubit_labels": '
#          + str(q_label).replace('\'', '\"') + ', ')
# data += '"n_qubits": ' + str(n_classical_reg) + ', '
# data += '"qreg_sizes": [["q", ' + str(n_qubits) + ']], '
# data += '"clbit_labels": ' + str(c_label).replace('\'', '\"') + ', '
# data += '"memory_slots": ' + str(n_classical_reg) + ', '
# data += '"creg_sizes": [["c", ' + str(n_classical_reg) + ']], '
# data += ('"name": "circuit0"}, "instructions": ' + instruction_str
#          + '}]}')

# json_step3 = {
#     'data': data,
#     'params': {
#         'access_token': None
#     },
#     'timeout': (5.0, None)
# }
# request = super(IBMQ, self).put(r_json['url'], **json_step3)
# request.raise_for_status()

# # STEP4: CONFIRM UPLOAD
# json_step4 = {
#     'data': None,
#     'json': None,
#     'timeout': (self.timeout, None)
# }
# upload_data_url = upload_endpoint_url.replace('jobUploadUrl',
#                                               'jobDataUploaded')
# request = super(IBMQ, self).post(upload_data_url, **json_step4)
# request.raise_for_status()
# r_json = request.json()
# execution_id = upload_endpoint_url.split('/')[-2]

# return execution_id











# # calibration info for a given processor [WIP] 
# url_back_calib = "https://api.quantum-computing.ibm.com/api/Backends/$(id_back[1])/calibration?access_token=$(id)"
# response_back_calib = HTTP.get(url_back_calib)
# response_back_json_calib = String(response_back.body)
# response_back_parsed_calib = JSON.parse(response_back_json)

