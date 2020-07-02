# RESTful API to expose the Chaincode

The RESTful API is a Node.js application that uses the Fabric SDK to interact with the Fabric chaincode
and exposes the chaincode functions as REST APIs. This allows loose coupling between the UI application
and the underlying Fabric network.

## Pre-requisites
The REST API server will run on the Fabric client node.

SSH into the Fabric client node and clone this repo. 

```
cd ~
git clone https://github.com/token-project/token.tts.git
```

You will need to set the context before carrying out any Fabric CLI commands.


## Step 1 - Install Node
On the Fabric client node.

Install Node.js. We will use v8.x.

```
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash
```

```
. ~/.nvm/nvm.sh
nvm install lts/carbon
nvm use lts/carbon
```

Amazon Linux seems to be missing g++, so:

```
sudo yum install gcc-c++ -y
```

## Step 2 - Install dependencies
On the Fabric client node.

```
cd ~/token.tts/rest-api
npm install
```

## Step 3 - Generate a connection profile
On the Fabric client node.

The REST API needs a connection profile to connect to the Fabric network. Connection profiles describe
the Fabric network and provide information needed by the Node.js application in order to connect to the
Fabric network. The instructions below will auto-generate a connection profile. 

Generate the connection profile using the script below and check that the connection profile contains 
URL endpoints for the peer, ordering service and CA, an 'mspid', a 'caName', and that the admin username and password
match those you entered when creating the Fabric network. If they do not match, edit the connection profile
and update them. The connection profile can be found here: `~/token.tts/tmp/connection-profile/connection-profile.yaml`

```
cd ~/token.tts/rest-api/connection-profile
./gen-connection-profile.sh
more ~/token.tts/tmp/connection-profile/connection-profile.yaml
```

Check the config file used by app.js. Make sure the peer name in config.json (under 'peers:') is 
the same as the peer name in the connection profile. Also check that the admin username and 
password are correct and match the values you updated in the connection profile.

```
cd ~/token.tts/rest-api
vi config.json
```

config.json should look something like this:

```
{
    "host":"localhost",
    "port":"3000",
    "jwt_expiretime": "36000",
    "channelName":"mychannel",
    "chaincodeName":"tts",
    "eventWaitTime":"30000",
    "peers":[
        "peer1"
    ],
    "admins":[
       {
          "username":"admin",
          "secret":"adminpwd"
       }
    ]
 }
```

## Step 4 - Run the REST API Node.js application
On the Fabric client node.

Run the app (in the background if you prefer):

```
cd ~/token.tts/rest-api
nvm use lts/carbon
node app.js &
```

## Step 5 - Test the REST API
On the Fabric client node.

Once the app is running you can register an identity, and then start to execute chaincode. The command
below registers a user identity with the Fabric CA. This user identity is then used to run chaincode
queries and invoke transactions.

### Register/enroll a user:

request:
```
curl -s -X POST http://localhost:3000/users -H "content-type: application/x-www-form-urlencoded" -d 'username=michael&orgName=Org1'
```

response:
```
{"success":true,"secret":"","message":"michael enrolled Successfully"}
```

### POST a Stamp

request:
```
curl -s -X POST "http://localhost:3000/stamps" -H "content-type: application/json" -d '{ 
   "hash": "2f3f3a85340bde09b505b0d37235d1d32a674e43a66229f9a205e7d8d5328ed1" 
}'
```

response:
A transaction ID, which can be ignored:

```
{"transactionId":"2f3f3a85340bde09b505b0d37235d1d32a674e43a66229f9a205e7d8d5328ed1"}
```

### Check a Stamp

request:
```
curl -s -X GET   "http://localhost:3000/stamp/<stampId>" -H "content-type: application/json"
```


### Get all Stamps

request:
```
curl -s -X GET   "http://localhost:3000/donors" -H "content-type: application/json"
```