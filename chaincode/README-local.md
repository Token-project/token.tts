# Installing on Hyperledger Fabric

## Pre-requisites

To run and test this application locally you will need a Hyperledger Fabric network running, either
locally on your laptop or on an cloud instance.

Follow the instructions here to install the fabric-samples repo, and download the
Fabric binaries and Docker images. This will download the latest version of Fabric: 

https://hyperledger-fabric.readthedocs.io/en/latest/install.html

Now, we need to install a slightly different version of fabric-samples. The default fabric-samples repo above
does not start a fabric-ca, which we need to run our application.

The fabric-samples version we run below has been modified to start a fabric-ca.

```
cd ~
mv fabric-samples fabric-samples-1.3
git clone https://github.com/mahoney1/fabric-samples.git
cd fabric-samples
git checkout multi-org
cp -R ../fabric-samples-1.3/bin .
cp -R ../fabric-samples-1.3/config .
```

Change to the fabric-samples directory. We will use the first network so change to this directory:

```
cd first-network
```

## Start the Fabric network

The first time you start the network you should generate the keys/certs:

```
./byfn.sh generate
```

Then start the network. The `-a` argument below will start fabric-ca in addition to the other Fabric components:

```
./byfn.sh up -s couchdb -l node -a
```

## Install or update the chaincode

Now, how do we get the chaincode into the Fabric network so we can install and instantiate it?

We'll install the chaincode from the CLI container. This container maps a `chaincode` folder from your local host 
into the container, so we simply need to copy our chaincode to this folder.

Clone this repo, which contains the chaincode:

```
cd ~
git clone https://github.com/token-project/token.tts.git
```

In your terminal window, change to the directory containing the chaincode:

```
cd ~
cd token.tts/chaincode
```

Update the REPODIR variable in the statements below to match the location of your fabric-samples repo, and
then execute all the commands in your terminal window:

If installing on Mac:

```
cd ~/Documents/apps/token.tts/chaincode
REPODIR=/Users/edgema/Documents/apps/fabric-samples
rm $REPODIR/chaincode/tts/*
mkdir -p $REPODIR/chaincode/tts
cp src/package.json $REPODIR/chaincode/tts
cp src/token.js $REPODIR/chaincode/tts
```

If installing on an EC2 instance:

```
cd ~/token.tts/chaincode
REPODIR=/home/ubuntu/fabric-samples
rm $REPODIR/chaincode/tts/*
mkdir -p $REPODIR/chaincode/tts
cp src/package.json $REPODIR/chaincode/tts
cp src/token.js $REPODIR/chaincode/tts
```

To confirm that this is now visible inside your CLI container, exec into the container:

```
docker exec -it cli bash
```

Inside the CLI container:

```
# ls /opt/gopath/src/github.com/chaincode/tts
package.json  tts.js
```

You can repeat this process whenever you update the chaincode.

Install the chaincode on the peer nodes. You'll install it to each peer node separately by setting the appropriate ENV variables
before doing a `peer chaincode install`. This simply copies the chaincode to the peer node. If you are upgrading the chaincode,
i.e. creating a new version, you 'll need to increment the version number in the statements below (the -v option).

In the byfn network there are 4 peer nodes. You'll copy to each one individually by changing the ENV variables as appropriate

### Shortcut - statements for all 4 peers

```
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
peer chaincode install -n tts -v 7.0 -l node -p /opt/gopath/src/github.com/chaincode/tts

export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=peer1.org1.example.com:7051
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt
peer chaincode install -n tts -v 7.0 -l node -p /opt/gopath/src/github.com/chaincode/tts

export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=peer0.org2.example.com:7051
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
peer chaincode install -n tts -v 7.0 -l node -p /opt/gopath/src/github.com/chaincode/tts

export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=peer1.org2.example.com:7051
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/ca.crt
peer chaincode install -n tts -v 7.0 -l node -p /opt/gopath/src/github.com/chaincode/tts

export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
peer chaincode upgrade -C mychannel -n tts -l node -v 7.0 -c '{"Args":["init"]}' -P "AND ('Org1MSP.peer','Org2MSP.peer')" -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```

### peer0.org1

```
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
peer chaincode install -n tts -v 7.0 -l node -p /opt/gopath/src/github.com/chaincode/tts
```

### peer1.org1

```
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=peer1.org1.example.com:7051
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt
peer chaincode install -n tts -v 7.0 -l node -p /opt/gopath/src/github.com/chaincode/tts
```

### peer0.org2

```
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=peer0.org2.example.com:7051
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
peer chaincode install -n tts -v 7.0 -l node -p /opt/gopath/src/github.com/chaincode/tts
```

### peer1.org2

```
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=peer1.org2.example.com:7051
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/ca.crt
peer chaincode install -n tts -v 7.0 -l node -p /opt/gopath/src/github.com/chaincode/tts
```

## Instantiate the chaincode

The chaincode only needs to be instantiated on a single peer node. Since we are using TLS we pass the TLS cert, which is
conveniently stored in the CLI.

If you are upgrading the chaincode, you'll use the `upgrade` command below instead of the `instantiated` command:

### peer0.org1 - instantiate

```
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
peer chaincode instantiate -C mychannel -n tts -l node -v 7.0 -c '{"Args":["init"]}' -P "AND ('Org1MSP.peer','Org2MSP.peer')" -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```

### peer0.org1 - upgrade

```
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
peer chaincode upgrade -C mychannel -n tts -l node -v 7.0 -c '{"Args":["init"]}' -P "AND ('Org1MSP.peer','Org2MSP.peer')" -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```

Check that the chaincode was instantiated on the channel. You can run this after either an `upgrade` or an `instantiate` 

```
# peer chaincode list --instantiated -C mychannel -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem 
Get instantiated chaincodes on channel mychannel:
Name: tts, Version: 7.0, Path: /opt/gopath/src/github.com/chaincode/chaincode_example02/node/, Escc: escc, Vscc: vscc
Name: tts, Version: 7.0, Path: /opt/gopath/src/github.com/chaincode/tts, Escc: escc, Vscc: vscc
```

## Invoke transactions to add participants in the network

To invoke transaction must have installed the chaincode on the two peers used in the first-network: peer0.org1 and peer0.org2.

The statements for querying the chaincode and invoking transactions can be found in ./test-chaincode.sh

## Directly query the CouchDB database to see your data

```
docker exec -it cli bash
```

Find the list of CouchDB databases:

```
curl couchdb0:5984/_all_dbs
```

Check the docs in the db:

```
curl couchdb0:5984/mychannel_tts/_all_docs
curl -X POST 'http://couchdb0:5984/mychannel_tts/_find' -H 'Content-Type: application/json' --data '{"selector": {"docType": "stamp"}}'
curl -X POST 'http://couchdb0:5984/mychannel_tts/_find' -H 'Content-Type: application/json' --data '{"selector": {"docType": "stamp", "hash":"1234"}}'
```

## Cleanup

```
./byfn.sh down
docker rm -f $(docker ps -aq)
docker network prune
```

# Troubleshooting

Chaincode endorsed by multiple endorsing peers may throw this error:
```
Error: could not assemble transaction: ProposalResponsePayloads do not match - proposal response: version:1 response:<status:200 > payload: ...
```

The usual reason for this is different values in the write set produced by different peers. This can arise if your
chaincode tries to generate a value, for example, if you use `new Date()` to assign a timestamp to a field in your
chaincode. The date on each endorsing peer node could be slightly different, which causes the Fabric validation process to fail.
Another cause could be trying to generate a sequence number or unique ID (such as a UUID) in chaincode. Again, the results
may differ on the endorsing peers and the transaction proposal will fail the validation checks.
