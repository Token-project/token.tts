# TOKEN TTS Chaincode

The instructions in this README will help you to install the TTS chaincode on your
Fabric network

All steps are carried out on the Fabric client node

## Pre-requisites

SSH into the Fabric client node and clone this repo

```
cd ~
git clone https://github.com/token-project/token.tts.git
```

You will need to set the context before carrying out any Fabric CLI commands.

## Step 1 - Copy the chaincode into the CLI container

The Fabric CLI container that is running on your Fabric client node (do `docker ps` to see it)
mounts a folder from the Fabric client node instance: /home/user/fabric-samples/chaincode.
You can see this by looking at the docker config. Look at the `Mounts` section in the output where
you'll see `/home/user/fabric-samples/chaincode` mounted into the Docker container:

```
docker inspect cli
```

You should already have this folder on your Fabric client node as it was created earlier. Copying the 
chaincode into this folder will make it accessible inside the Fabric CLI container.

```
cd ~
mkdir -p ./fabric-samples/chaincode/tts
cp ./token.tts/chaincode/src/* ./fabric-samples/chaincode/tts
```

## Step 2 - Install the chaincode on your peer

Before executing any chaincode functions, the chaincode must be installed on the peer node. Chaincode
must be installed on every peer that wants to invoke transactions or run the query functions in the
chaincode.

Notice we are using the `-l node` flag, as our chaincode is written in Node.js.

```
docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/tts-chain.pem" \
    -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" -e "CORE_PEER_ADDRESS=$PEER"  \
    cli peer chaincode install -n ledger -l node -v v0 -p /opt/gopath/src/github.com/token
```

Expected response:

```
2018-11-15 06:39:47.625 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 001 Using default escc
2018-11-15 06:39:47.625 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 002 Using default vscc
2018-11-15 06:39:47.625 UTC [container] WriteFolderToTarPackage -> INFO 003 rootDirectory = /opt/gopath/src/github.com/token
2018-11-15 06:39:47.636 UTC [chaincodeCmd] install -> INFO 004 Installed remotely response:<status:200 payload:"OK" >
```

## Step 3 - Instantiate the chaincode on the channel

Instantiation initlizes the chaincode on the channel, i.e. it binds the chaincode to a specific channel.
Instantiation is treated as a Fabric transaction. In fact, when chaincode is instantiated, the Init function
on the chaincode is called. Instantiation also sets the endorsement policy for this version of the chaincode
on this channel. In the example below we are not explictly passing an endorsement policy, so the default
policy of 'any member of the organizations in the channel' is applied.

It can take up to 30 seconds to instantiate chaincode on the channel.

```
docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/tts-chain.pem" \
    -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" -e "CORE_PEER_ADDRESS=$PEER"  \
    cli peer chaincode instantiate -o $ORDERER -C mychannel -n ledger -v v0 -c '{"Args":["init"]}' --cafile /opt/home/tts-chain.pem --tls
```

Expected response:
(Note this might fail if the chaincode has been previously instantiated. Chaincode only needs to be
instantiated once on a channel)

```
2018-11-15 06:41:02.847 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 001 Using default escc
2018-11-15 06:41:02.847 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 002 Using default vscc
```

## Step 4 - Query the chaincode

Query all donors
```
docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/tts-chain.pem" \
    -e "CORE_PEER_ADDRESS=$PEER" -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" \
    cli peer chaincode query -C mychannel -n ledger -c '{"Args":["queryAllStamp"]}'
```

Expected response:
This is correct as we do not have any donors in our network yet. We'll add one in the next step.

```
[]
```

## Move on to Part 2

* [Part 2:](../rest-api/README.md) Run the RESTful API server. 

