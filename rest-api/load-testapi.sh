#!/bin/bash

#
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
#

# Test script for testing the REST API
# Set the exports below to point to the REST API hostname/port and run the script

# The export statements below can be used to point to either localhost or to an ELB endpoint, 
# depending on where the REST API server is running 
export ENDPOINT=Fabric-ELB-205962472.us-west-2.elb.amazonaws.com
export PORT=80
#export ENDPOINT=localhost
#export PORT=3000
set +e
echo installing jq
sudo yum install jq
echo To test, run the API server as per the instructions in the README, then execute this script on the command line
echo 'NOTE: the logger for the REST API server (in app.js) should be running at INFO level, not DEBUG'
echo
RED='\033[0;31m'
RESTORE='\033[0m'
echo connecting to server: $ENDPOINT:$PORT
echo
echo '---------------------------------------'
echo Registering a user
echo '---------------------------------------'
echo 'Register User'
USERID=$(uuidgen)
echo
response=$(curl -s -X POST http://${ENDPOINT}:${PORT}/users -H 'content-type: application/x-www-form-urlencoded' -d "username=${USERID}&orgName=Org1")
echo $response
echo Response should be: {"success":true,"secret":"","message":"$USERID enrolled Successfully"}
echo
echo Checking response:
echo
ret=$(echo $response | jq '.message | contains("enrolled Successfully")')
if [ $ret ]; then
        echo test case passed
else
        echo -e ${RED} ERROR - test case failed - user was not enrolled ${RESTORE}
fi
echo $response | jq ".message" | grep "$USERID enrolled Successfully"
echo
echo '---------------------------------------'
echo Donors
echo '---------------------------------------'
echo 'Create Donor'
echo
DONOR1=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/donors -H 'content-type: application/json' -d '{ 
   "donorUserName": "'"${DONOR1}"'", 
   "email": "abc@def.com", 
   "registeredDate": "2018-10-22T11:52:20.182Z" 
}')
echo "Transaction ID is $TRX_ID"
echo
DONOR2=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/donors -H 'content-type: application/json' -d '{ 
   "donorUserName": "'"${DONOR2}"'", 
   "email": "abc@def.com", 
   "registeredDate": "2018-10-22T11:52:20.182Z" 
}')
echo "Transaction ID is $TRX_ID"
echo
echo 'Query all donors'
echo
curl -s -X GET http://${ENDPOINT}:${PORT}/donors -H 'content-type: application/json'
echo
echo 'Query specific donors'
echo
response=$(curl -s -X GET http://${ENDPOINT}:${PORT}/donors/${DONOR1} -H 'content-type: application/json')
echo $response
echo
ret=$(echo $response | jq '.[].docType' | jq 'contains("donor")')
echo $ret
if $ret ; then
        echo test case passed
else
        echo -e ${RED} ERROR - test case failed - query specific donors does not match expected result. Result is: $ret ${RESTORE}
fi
echo
echo '---------------------------------------'
echo LEDGER
echo '---------------------------------------'
echo 'Create LEDGER'
echo
LEDGER1=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/stamps -H 'content-type: application/json' -d '{ 
    "stampRegistrationNumber": "'"${LEDGER1}"'", 
    "stampName": "Pets In Need",
    "stampDescription": "We help pets in need",
    "address": "1 Pet street",
    "contactNumber": "82372837",
    "contactEmail": "pets@petco.com"
}')
echo "Transaction ID is $TRX_ID"
echo
echo 'Create LEDGER'
echo
LEDGER2=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/stamps -H 'content-type: application/json' -d '{ 
    "stampRegistrationNumber": "'"${LEDGER2}"'", 
    "stampName": "Pets In Need",
    "stampDescription": "We help pets in need",
    "address": "1 Pet street",
    "contactNumber": "82372837",
    "contactEmail": "pets@petco.com"
}')
echo "Transaction ID is $TRX_ID"
echo
echo 'Query all LEDGERs'
echo
curl -s -X GET http://${ENDPOINT}:${PORT}/stamps -H 'content-type: application/json'
echo
echo 'Query specific LEDGERs'
echo
response=$(curl -s -X GET http://${ENDPOINT}:${PORT}/stamps/${LEDGER1} -H 'content-type: application/json')
echo $response
echo
ret=$(echo $response | jq '.[].docType' | jq 'contains("stamp")')
echo $ret
if $ret ; then
        echo test case passed
else
        echo -e ${RED} ERROR - test case failed - query specific stamp does not match expected result. Result is: $response ${RESTORE}
fi
echo '---------------------------------------'
echo Rating
echo '---------------------------------------'
echo 'Create Rating'
echo
RATING1=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/ratings -H 'content-type: application/json' -d '{ 
   "donorUserName": "'"${DONOR1}"'", 
   "stampRegistrationNumber": "'"${LEDGER2}"'", 
   "rating": 1
}')
echo "Transaction ID is $TRX_ID"
echo
RATING2=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/ratings -H 'content-type: application/json' -d '{ 
   "donorUserName": "'"${DONOR2}"'", 
   "stampRegistrationNumber": "'"${LEDGER2}"'", 
   "rating": 3
}')
echo "Transaction ID is $TRX_ID"
echo
echo 'Query specific ratings'
echo
curl -s -X GET http://${ENDPOINT}:${PORT}/ratings/${LEDGER2}/${DONOR1}/ -H 'content-type: application/json'
echo
echo 'Query ratings for an LEDGER'
echo
response=$(curl -s -X GET http://${ENDPOINT}:${PORT}/stamps/${LEDGER2}/ratings -H 'content-type: application/json')
echo $response
echo
ret=$(echo $response | jq '.[].docType' | jq 'contains("rating")')
echo $ret
if $ret ; then
        echo test case passed
else
        echo -e ${RED} ERROR - test case failed - query specific rating does not match expected result. Result is: $response ${RESTORE}
fi
echo
echo '---------------------------------------'
echo Donation
echo '---------------------------------------'
echo
echo 'Create Donation'
echo
DONATION1=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/donations -H 'content-type: application/json' -d '{ 
        "donationId": "'"${DONATION1}"'",
        "donationAmount": 100,
        "donationDate": "2020-02-20T12:41:59.582Z",
        "donorUserName": "'"${DONOR1}"'",
        "stampRegistrationNumber": "'"${LEDGER1}"'"
}')
echo "Transaction ID is $TRX_ID"
echo
DONATION2=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/donations -H 'content-type: application/json' -d '{ 
        "donationId": "'"${DONATION2}"'",
        "donationAmount": 999,
        "donationDate": "2020-02-20T12:41:59.582Z",
        "donorUserName": "'"${DONOR2}"'",
        "stampRegistrationNumber": "'"${LEDGER1}"'"
}')
echo "Transaction ID is $TRX_ID"
echo
DONATION3=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/donations -H 'content-type: application/json' -d '{ 
        "donationId": "'"${DONATION3}"'",
        "donationAmount": 75,
        "donationDate": "2020-02-20T12:41:59.582Z",
        "donorUserName": "'"${DONOR1}"'",
        "stampRegistrationNumber": "'"${LEDGER2}"'"
}')
echo "Transaction ID is $TRX_ID"
echo
echo 'Query all Donations'
echo
curl -s -X GET http://${ENDPOINT}:${PORT}/donations -H 'content-type: application/json'
echo
echo 'Query specific Donations'
echo
curl -s -X GET http://${ENDPOINT}:${PORT}/donations/${DONATION2} -H 'content-type: application/json'
echo
echo 'Query Donations for a donor'
echo
curl -s -X GET http://${ENDPOINT}:${PORT}/donors/${DONOR1}/donations/ -H 'content-type: application/json'
echo
echo 'Query Donations for an LEDGER'
echo
response=$(curl -s -X GET http://${ENDPOINT}:${PORT}/stamps/${LEDGER1}/donations/ -H 'content-type: application/json')
echo $response
echo
ret=$(echo $response | jq '.[].docType' | jq 'contains("donation")')
echo $ret
if $ret ; then
        echo test case passed
else
        echo -e ${RED} ERROR - test case failed - query specific donation does not match expected result. Result is: $response ${RESTORE}
fi
echo
echo '---------------------------------------'
echo Stamp
echo '---------------------------------------'
echo 'Create Stamp'
echo
SPENDID=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/stamp -H 'content-type: application/json' -d '{ 
        "stampRegistrationNumber": "'"${LEDGER1}"'",
        "stampId": "'"${SPENDID}"'",
        "stampDescription": "Peter Pipers Poulty Portions for Pets",
        "stampDate": "2020-02-20T12:41:59.582Z",
        "stampAmount": 33
}')
echo "Transaction ID is $TRX_ID"
echo
SPENDID=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/stamp -H 'content-type: application/json' -d '{ 
        "stampRegistrationNumber": "'"${LEDGER2}"'",
        "stampId": "'"${SPENDID}"'",
        "stampDescription": "Peter Pipers Poulty Portions for Pets",
        "stampDate": "2020-02-20T12:41:59.582Z",
        "stampAmount": 100
}')
echo "Transaction ID is $TRX_ID"
echo
SPENDID=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/stamp -H 'content-type: application/json' -d '{ 
        "stampRegistrationNumber": "'"${LEDGER1}"'",
        "stampId": "'"${SPENDID}"'",
        "stampDescription": "Peter Pipers Poulty Portions for Pets",
        "stampDate": "2020-02-20T12:41:59.582Z",
        "stampAmount": 123
}')
echo "Transaction ID is $TRX_ID"
echo
SPENDID=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/stamp -H 'content-type: application/json' -d '{ 
        "stampRegistrationNumber": "'"${LEDGER1}"'",
        "stampId": "'"${SPENDID}"'",
        "stampDescription": "Peter Pipers Poulty Portions for Pets",
        "stampDate": "2020-02-20T12:41:59.582Z",
        "stampAmount": 1000
}')
echo "Transaction ID is $TRX_ID"
echo
SPENDID=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/stamp -H 'content-type: application/json' -d '{ 
        "stampRegistrationNumber": "'"${LEDGER1}"'",
        "stampId": "'"${SPENDID}"'",
        "stampDescription": "Peter Pipers Poulty Portions for Pets",
        "stampDate": "2020-02-20T12:41:59.582Z",
        "stampAmount": 23
}')
echo "Transaction ID is $TRX_ID"
echo ${SPENDID}
echo
echo 'Query all Stamps'
echo
curl -s -X GET http://${ENDPOINT}:${PORT}/stamp -H 'content-type: application/json'
echo
echo 'Query specific Stamps'
sleep 2
echo
curl -s -X GET http://${ENDPOINT}:${PORT}/stamp/${SPENDID} -H 'content-type: application/json'
echo
echo 'Query Stamp by LEDGER'
echo
response=$(curl -s -X GET http://${ENDPOINT}:${PORT}/stamps/${LEDGER1}/stamp -H 'content-type: application/json')
echo $response
echo
ret=$(echo $response | jq '.[].docType' | jq 'contains("stamp")')
echo $ret
if $ret ; then
        echo test case passed
else
        echo -e ${RED} ERROR - test case failed - query specific stamp does not match expected result. Result is: $response ${RESTORE}
fi
echo
echo 'Query StampAllocations by donation'
echo
echo
response=$(curl -s -X GET http://${ENDPOINT}:${PORT}/donations/${DONATION1}/stampallocations -H 'content-type: application/json')
echo $response
echo
ret=$(echo $response | jq '.[].docType' | jq 'contains("stampAllocation")')
echo $ret
if $ret ; then
        echo test case passed
else
        echo -e ${RED} ERROR - test case failed - query specific stampallocation does not match expected result. Result is: $response ${RESTORE}
fi
echo
echo 'Query StampAllocations by stamp'
echo
echo
response=$(curl -s -X GET http://${ENDPOINT}:${PORT}/stamp/${SPENDID}/stampallocations -H 'content-type: application/json')
echo $response
echo
ret=$(echo $response | jq '.[].docType' | jq 'contains("stampAllocation")')
echo $ret
if $ret ; then
        echo test case passed
else
        echo -e ${RED} ERROR - test case failed - query specific stampallocation does not match expected result. Result is: $response ${RESTORE}
fi
echo
echo 'Query all StampAllocations'
echo
curl -s -X GET http://${ENDPOINT}:${PORT}/stampallocations -H 'content-type: application/json'
echo
echo 'Send a mixture of donations and stamps'
echo
echo 'Create Donations & Stamps'
echo
DONATION1=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/donations -H 'content-type: application/json' -d '{ 
        "donationId": "'"${DONATION1}"'",
        "donationAmount": 111,
        "donationDate": "2020-02-20T12:41:59.582Z",
        "donorUserName": "'"${DONOR1}"'", 
        "stampRegistrationNumber": "'"${LEDGER1}"'"
}')
echo "Transaction ID is $TRX_ID"
echo
DONATION1=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/donations -H 'content-type: application/json' -d '{ 
        "donationId": "'"${DONATION1}"'",
        "donationAmount": 222,
        "donationDate": "2020-02-20T12:41:59.582Z",
        "donorUserName": "'"${DONOR2}"'", 
        "stampRegistrationNumber": "'"${LEDGER1}"'"
}')
echo "Transaction ID is $TRX_ID"
echo
DONATION1=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/donations -H 'content-type: application/json' -d '{ 
        "donationId": "'"${DONATION1}"'",
        "donationAmount": 222,
        "donationDate": "2020-02-20T12:41:59.582Z",
        "donorUserName": "'"${DONOR1}"'", 
        "stampRegistrationNumber": "'"${LEDGER2}"'"
}')
echo "Transaction ID is $TRX_ID"
echo
SPENDID=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/stamp -H 'content-type: application/json' -d '{ 
        "stampRegistrationNumber": "'"${LEDGER1}"'",
        "stampId": "'"${SPENDID}"'",
        "stampDescription": "Peter Pipers Poulty Portions for Pets",
        "stampDate": "2020-02-20T12:41:59.582Z",
        "stampAmount": 666
}')
echo "Transaction ID is $TRX_ID"
echo
SPENDID=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/stamp -H 'content-type: application/json' -d '{ 
        "stampRegistrationNumber": "'"${LEDGER1}"'",
        "stampId": "'"${SPENDID}"'",
        "stampDescription": "Peter Pipers Poulty Portions for Pets",
        "stampDate": "2020-02-20T12:41:59.582Z",
        "stampAmount": 227
}')
echo "Transaction ID is $TRX_ID"
echo
SPENDID=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/stamp -H 'content-type: application/json' -d '{ 
        "stampRegistrationNumber": "'"${LEDGER2}"'",
        "stampId": "'"${SPENDID}"'",
        "stampDescription": "Peter Pipers Poulty Portions for Pets",
        "stampDate": "2020-02-20T12:41:59.582Z",
        "stampAmount": 1
}')
echo "Transaction ID is $TRX_ID"
echo
SPENDID=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/stamp -H 'content-type: application/json' -d '{ 
        "stampRegistrationNumber": "'"${LEDGER2}"'",
        "stampId": "'"${SPENDID}"'",
        "stampDescription": "Peter Pipers Poulty Portions for Pets",
        "stampDate": "2020-02-20T12:41:59.582Z",
        "stampAmount": 77
}')
echo "Transaction ID is $TRX_ID"
echo
DONATION1=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/donations -H 'content-type: application/json' -d '{ 
        "donationId": "'"${DONATION1}"'",
        "donationAmount": 875,
        "donationDate": "2020-02-20T12:41:59.582Z",
        "donorUserName": "'"${DONOR2}"'", 
        "stampRegistrationNumber": "'"${LEDGER1}"'"
}')
echo "Transaction ID is $TRX_ID"
echo
DONATION1=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/donations -H 'content-type: application/json' -d '{ 
        "donationId": "'"${DONATION1}"'",
        "donationAmount": 1,
        "donationDate": "2020-02-20T12:41:59.582Z",
        "donorUserName": "'"${DONOR1}"'", 
        "stampRegistrationNumber": "'"${LEDGER2}"'"
}')
echo "Transaction ID is $TRX_ID"
echo
SPENDID=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/stamp -H 'content-type: application/json' -d '{ 
        "stampRegistrationNumber": "'"${LEDGER2}"'",
        "stampId": "'"${SPENDID}"'",
        "stampDescription": "Peter Pipers Poulty Portions for Pets",
        "stampDate": "2020-02-20T12:41:59.582Z",
        "stampAmount": 0
}')
echo "Transaction ID is $TRX_ID"
echo
DONATION1=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/donations -H 'content-type: application/json' -d '{ 
        "donationId": "'"${DONATION1}"'",
        "donationAmount": 0,
        "donationDate": "2020-02-20T12:41:59.582Z",
        "donorUserName": "'"${DONOR1}"'", 
        "stampRegistrationNumber": "'"${LEDGER2}"'"
}')
echo "Transaction ID is $TRX_ID"
echo
echo 'Query Blockinfo for a record key'
echo
curl -s -X GET http://${ENDPOINT}:${PORT}/blockinfos/stampAllocation/keys/12345 -H 'content-type: application/json'
