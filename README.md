# Quickstart

## Login
The `authenticate` method will log you in. 
```
user = authenticate(token)
```
This creates a `IBMQUser` type.

## Creating register
The `createreg` will make a `Yao.AbstractRegister` type viz. `IBMQReg` that holds vital info regarding communication with the IBMQ backend.
```
reg = createreg(user)
```
will list the available backends where you can select various backends based on you circuit.

## Uploading the circuit
```
job = apply!(reg, [qc])
```
The `apply!(::IBMQReg, ::Array{ChainBlock})` accepts multiple circuits in an array since some backends are capable of running multiple expertiments 

## Checking Status
```
stats = status(job)
```
returns the status of the job. 
Possible return values are: 
`COMPLETED`, `VALIDATING`, `QUEUED`, `RUNNING`,  `ERROR_VALIDATING_JOB`, `ERROR_RUNNING_JOB`

## Fetching results
If the `status()` method returns `COMPLETED`, one can fetch the results with the `getresult()` method.
```
getresult(job)
```
The resulting data is a Dict format.