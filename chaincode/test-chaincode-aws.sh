#!/bin/bash

# Copyright 2020 FundingBox Accelerator S.P. z.o.o. All Rights Reserved.
# 
# Licensed under the Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# or in the "license" file accompanying this file. This file is distributed 
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either 
# express or implied. See the License for the specific language governing 
# permissions and limitations under the License.

echo Run this script on the Fabric client node, OUTSIDE of the CLI container
echo
echo Add Donors

# Note the Args below - we are passing in a JSON payload, rather than the usual array of strings that Fabric requires. 
# IMO this is much better as we can clearly see what each argument means, rather than just passing an array of strings

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/tts-chain.pem" \ 
-e "CORE_PEER_ADDRESS=$PEER" -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" \ 
cli peer chaincode invoke -o $ORDERER -C $CHANNEL -n $CHAINCODENAME \ 
-c '{"Args":["createDonor","{\"donorUserName\": \"edge\", \"email\": \"edge@def.com\", \"registeredDate\": \"2018-10-22T11:52:20.182Z\"}"]}'

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/tts-chain.pem" \ 
-e "CORE_PEER_ADDRESS=$PEER" -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" \ 
cli peer chaincode invoke -o $ORDERER -C $CHANNEL -n $CHAINCODENAME \ 
-c '{"Args":["createDonor","{\"donorUserName\": \"braendle\", \"email\": \"braendle@def.com\", \"registeredDate\": \"2018-10-22T11:52:20.182Z\"}"]}'

echo Add LEDGERs

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/tts-chain.pem" \ 
-e "CORE_PEER_ADDRESS=$PEER" -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" \ 
cli peer chaincode invoke -o $ORDERER -C $CHANNEL -n $CHAINCODENAME \ 
-c '{"Args":["createLEDGER","{\"ledgerRegistrationNumber\": \"6322\", \"ledgerName\": \"Pets In Need\", \"ledgerDescription\": \"We help pets in need\", \"address\": \"1 Pet street\", \"contactNumber\": \"82372837\", \"contactEmail\": \"pets@petco.com\"}"]}'


docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/tts-chain.pem" \ 
-e "CORE_PEER_ADDRESS=$PEER" -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" \ 
cli peer chaincode invoke -o $ORDERER -C $CHANNEL -n $CHAINCODENAME \ 
-c '{"Args":["createLEDGER","{\"ledgerRegistrationNumber\": \"6323\", \"ledgerName\": \"Dogs In Need\", \"ledgerDescription\": \"We help dogs in need\", \"address\": \"1 Dog street\", \"contactNumber\": \"82372837\", \"contactEmail\": \"dogs@dogco.com\"}"]}'

echo Add Donation

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/tts-chain.pem" 
\ -e "CORE_PEER_ADDRESS=$PEER" -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" 
\ cli peer chaincode invoke -o $ORDERER -C $CHANNEL -n $CHAINCODENAME 
\ -c '{"Args":["createDonation","{\"donationId\": \"2211\", \"donationAmount\": 100, \"donationDate\": \"2020-02-20T12:41:59.582Z\", \"donorUserName\": \"edge\", \"ledgerRegistrationNumber\": \"6322\"}"]}'

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/tts-chain.pem" \ 
-e "CORE_PEER_ADDRESS=$PEER" -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" \ 
cli peer chaincode invoke -o $ORDERER -C $CHANNEL -n $CHAINCODENAME \ 
-c '{"Args":["createDonation","{\"donationId\": \"2212\", \"donationAmount\": 733, \"donationDate\": \"2020-02-20T12:41:59.582Z\", \"donorUserName\": \"braendle\", \"ledgerRegistrationNumber\": \"6322\"}"]}'

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/tts-chain.pem" \ 
-e "CORE_PEER_ADDRESS=$PEER" -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" \ 
cli peer chaincode invoke -o $ORDERER -C $CHANNEL -n $CHAINCODENAME \ 
-c '{"Args":["createDonation","{\"donationId\": \"2230\", \"donationAmount\": 450, \"donationDate\": \"2020-02-20T12:41:59.582Z\", \"donorUserName\": \"edge\", \"ledgerRegistrationNumber\": \"6323\"}"]}'

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/tts-chain.pem" \ 
-e "CORE_PEER_ADDRESS=$PEER" -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" \ 
cli peer chaincode invoke -o $ORDERER -C $CHANNEL -n $CHAINCODENAME \ 
-c '{"Args":["createDonation","{\"donationId\": \"2231\", \"donationAmount\": 29, \"donationDate\": \"2020-02-20T12:41:59.582Z\", \"donorUserName\": \"braendle\", \"ledgerRegistrationNumber\": \"6323\"}"]}'

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/tts-chain.pem" \ 
-e "CORE_PEER_ADDRESS=$PEER" -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" \ 
cli peer chaincode invoke -o $ORDERER -C $CHANNEL -n $CHAINCODENAME \ 
-c '{"Args":["createDonation","{\"donationId\": \"2232\", \"donationAmount\": 98, \"donationDate\": \"2020-02-20T12:41:59.582Z\", \"donorUserName\": \"braendle\", \"ledgerRegistrationNumber\": \"6323\"}"]}'

echo Add Spend

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/tts-chain.pem" \ 
-e "CORE_PEER_ADDRESS=$PEER" -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" \ 
cli peer chaincode invoke -o $ORDERER -C $CHANNEL -n $CHAINCODENAME \ 
-c '{"Args":["createStamp","{\"ledgerRegistrationNumber\": \"6322\", \"spendId\": \"2\", \"spendDescription\": \"Peter Pipers Poulty Portions for Pets\", \"spendDate\": \"2020-02-20T12:41:59.582Z\", \"spendAmount\": 33}"]}'

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/tts-chain.pem" \ 
-e "CORE_PEER_ADDRESS=$PEER" -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" \ 
cli peer chaincode invoke -o $ORDERER -C $CHANNEL -n $CHAINCODENAME \ 
-c '{"Args":["createStamp","{\"ledgerRegistrationNumber\": \"6322\", \"spendId\": \"3\", \"spendDescription\": \"Peter Pipers Poulty Portions for Pets\", \"spendDate\": \"2020-02-20T12:41:59.582Z\", \"spendAmount\": 651}"]}'

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/tts-chain.pem" \ 
-e "CORE_PEER_ADDRESS=$PEER" -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" \ 
cli peer chaincode invoke -o $ORDERER -C $CHANNEL -n $CHAINCODENAME \ 
-c '{"Args":["createStamp","{\"ledgerRegistrationNumber\": \"6323\", \"spendId\": \"4\", \"spendDescription\": \"Peter Pipers Poulty Portions for Pets\", \"spendDate\": \"2020-02-20T12:41:59.582Z\", \"spendAmount\": 323}"]}'

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/tts-chain.pem" \ 
-e "CORE_PEER_ADDRESS=$PEER" -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" \ 
cli peer chaincode invoke -o $ORDERER -C $CHANNEL -n $CHAINCODENAME \ 
-c '{"Args":["createStamp","{\"ledgerRegistrationNumber\": \"6323\", \"spendId\": \"5\", \"spendDescription\": \"Peter Pipers Poulty Portions for Pets\", \"spendDate\": \"2020-02-20T12:41:59.582Z\", \"spendAmount\": 21.765}"]}'

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/tts-chain.pem" \ 
-e "CORE_PEER_ADDRESS=$PEER" -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" \ 
cli peer chaincode invoke -o $ORDERER -C $CHANNEL -n $CHAINCODENAME \ 
-c '{"Args":["createStamp","{\"ledgerRegistrationNumber\": \"6323\", \"spendId\": \"6\", \"spendDescription\": \"Peter Pipers Poulty Portions for Pets\", \"spendDate\": \"2020-02-20T12:41:59.582Z\", \"spendAmount\": 625}"]}'

echo Query all donors

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/tts-chain.pem" \ 
-e "CORE_PEER_ADDRESS=$PEER" -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" \ 
cli peer chaincode query -C $CHANNEL -n $CHAINCODENAME -c '{"Args":["queryAllDonors"]}'

echo Query specific donor

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/tts-chain.pem" \ 
-e "CORE_PEER_ADDRESS=$PEER" -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" \ 
cli peer chaincode query -C $CHANNEL -n $CHAINCODENAME -c '{"Args":["queryDonor","{\"donorUserName\": \"edge\"}"]}'

echo Query all LEDGERs

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/tts-chain.pem" \ 
-e "CORE_PEER_ADDRESS=$PEER" -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" \ 
cli peer chaincode query -C $CHANNEL -n $CHAINCODENAME -c '{"Args":["queryAllLEDGERs"]}'

echo Query specific LEDGER

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/tts-chain.pem" \ 
-e "CORE_PEER_ADDRESS=$PEER" -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" \ 
cli peer chaincode query -C $CHANNEL -n $CHAINCODENAME -c '{"Args":["queryLEDGER","{\"ledgerRegistrationNumber\": \"6322\"}"]}'

echo Query all Donations

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/tts-chain.pem" \ 
-e "CORE_PEER_ADDRESS=$PEER" -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" \ 
cli peer chaincode query -C $CHANNEL -n $CHAINCODENAME -c '{"Args":["queryAllDonations"]}'

echo Query all Donations fir LEDGER

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/tts-chain.pem" \ 
-e "CORE_PEER_ADDRESS=$PEER" -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" \ 
cli peer chaincode query -C $CHANNEL -n $CHAINCODENAME -c '{"Args":["queryDonationsForLEDGER","{\"ledgerRegistrationNumber\": \"6322\"}"]}'

echo Query all Spend

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/tts-chain.pem" \ 
-e "CORE_PEER_ADDRESS=$PEER" -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" \ 
cli peer chaincode query -C $CHANNEL -n $CHAINCODENAME -c '{"Args":["queryAllStamps"]}'


echo Query all SpendAllocations

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/tts-chain.pem" \ 
-e "CORE_PEER_ADDRESS=$PEER" -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" \ 
cli peer chaincode query -C $CHANNEL -n $CHAINCODENAME -c '{"Args":["queryAllStampAllocations"]}'

echo Query SpendAllocations for a donation

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/tts-chain.pem" \ 
-e "CORE_PEER_ADDRESS=$PEER" -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" \ 
cli peer chaincode query -C $CHANNEL -n $CHAINCODENAME -c '{"Args":["queryStampAllocationForDonation","{\"donationId\": \"2212\"}"]}'

echo Query SpendAllocations for a spend record

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/tts-chain.pem" \ 
-e "CORE_PEER_ADDRESS=$PEER" -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" \ 
cli peer chaincode query -C $CHANNEL -n $CHAINCODENAME -c '{"Args":["queryStampAllocationForSpend","{\"spendId\": \"7\"}"]}'

echo Query history for a specific key

docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/tts-chain.pem" \ 
-e "CORE_PEER_ADDRESS=$PEER" -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" \ 
cli peer chaincode query -C $CHANNEL -n $CHAINCODENAME -c '{"Args":["queryHistoryForKey","{\"key\": \"136772b8c4bc84c09f86d8f936ae107a5fcbfbaa25b15d4a9ee7059dac1b312a-0\"}"]}'
