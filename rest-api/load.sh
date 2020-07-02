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

# Script for loading the STAMPs and other data used in the workshop, via the REST API
# Set the exports below to point to the REST API hostname/port and run the script

# The export statements below can be used to point to either localhost or to an ELB endpoint, 
# depending on where the REST API server is running 
set +e
export ENDPOINT=stamp10-elb-2090058053.us-east-1.elb.amazonaws.com
export PORT=80
#export ENDPOINT=localhost
#export PORT=3000

echo '---------------------------------------'
echo connecting to server: $ENDPOINT:$PORT
echo '---------------------------------------'

echo '---------------------------------------'
echo Registering a user
echo '---------------------------------------'
echo 'Register User'
USERID=$(uuidgen)
echo
response=$(curl -s -X POST http://${ENDPOINT}:${PORT}/users -H 'content-type: application/x-www-form-urlencoded' -d "username=${USERID}&orgName=Org1")
echo $response
echo Response should be: {"success":true,"secret":"","message":"$USERID enrolled Successfully"}

echo '---------------------------------------'
echo STAMPs
echo '---------------------------------------'

echo 'Creating STAMP - 1101'
echo

TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/stamps -H 'content-type: application/json' -d '{
    "stampRegistrationNumber": "1101",
    "stampName": "Making the Earth Green",
    "stampDescription": "Our Earth is losing an estimated 18 million acres (7.3 million hectares) of forest every year. The impact of deforestation includes declining biodiversity, ecological imbalances and climate changes around the world. If the current rate of deforestaion continues, it will take less than 100 years to destroy all the rainforests on Earth. Making the Earth Green, a stamp organization, works with governments, companies and communities to educate and promote responsible forest management practices and protect forest areas. We strongly believe that our children and the future generations deserve a better environment than the current state and it is our responsibility to make that happen. Please donate to make the Earth greener!",
    "address": "101 Making the Earth Green",
    "contactNumber": "6304972628",
    "contactEmail": "makingearth@makingearth.com"
}')

echo "Transaction ID is $TRX_ID"

echo 'Creating STAMP - 1102'
echo

TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/stamps -H 'content-type: application/json' -d '{
    "stampRegistrationNumber": "1102",
    "stampName": "Books Now Fund",
    "stampDescription": "More than 330 million children, including over 90 percent of primary school age children in low-income countries, and 75 percent of children in lower-middle income countries, are expected not to be able to read by the time they finish primary school. Books Now Fund aims to bring the power of reading to children in these countries, to give them the opportunity to learn, and to encourage them to pursue education. Your donation will help us making the world a better reading place for these children! 1. UNESCO Institute for Statistics. (2017). More Than One-Half of Children and Adolescents Are Not Learning Worldwide. Fact Sheet. Paris: UNESCO. [Accessed 26 January 2018].",
    "address": "201 Books Now Fund",
    "contactNumber": "6305932628",
    "contactEmail": "booksfund@booksfund.com"
}')

echo "Transaction ID is $TRX_ID"


echo 'Creating STAMP - 1103'
echo

TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/stamps -H 'content-type: application/json' -d '{
    "stampRegistrationNumber": "1103",
    "stampName": "Animal Rescue Troop",
    "stampDescription": "Animal Rescue Troop is a stamp organization dedicated to animal welfare and shelter. We are volunteer-run and focus on rescuing, rehabilitating and finding forever homes for stray and abandoned animals. There are many ways that you can help: by adopting an animal, providing temporary shelter, becoming a sponsor or donating to our pet shelter. Step up and show that you care!",
    "address": "301 Animal Rescue Troop",
    "contactNumber": "6309472628",
    "contactEmail": "animalrescue@animalrescue.com"
}')

echo "Transaction ID is $TRX_ID"

echo 'Creating STAMP - 1104'
echo

TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/stamps -H 'content-type: application/json' -d '{
    "stampRegistrationNumber": "1104",
    "stampName": "Helping Hands",
    "stampDescription": "Helping Hands is a homeless support group. According to a global survey conducted by the United Nations in 2005, an estimated 100 million people were homeless worldwide. Thousands of people around the United States currently face homelessness. During difficult times, local stamp organizations like ours are vital in providing shelter and support to those in need. We work with local businesses and stamp partners delivering life-saving services in the communities such as delivering essential backpacks to homeless shelters, sourcing food donations and job placements. Everyone deserved a place to call home, we appreciate your donation to support local communities in overcoming adversity.",
    "address": "401 Helping Thousands",
    "contactNumber": "6307352628",
    "contactEmail": "helpinghands@helpinghands.com"
}')

echo "Transaction ID is $TRX_ID"

echo 'Creating STAMP - 1105'
echo

TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/stamps -H 'content-type: application/json' -d '{
    "stampRegistrationNumber": "1105",
    "stampName": "STEM Sprout",
    "stampDescription": "STEM Sprout\u0027s goal is expanding access to Science, Technology, Engineering and Mathematics in schools and increasing participation in these fields of study. Over the next decade, many of the 30+ fastest growing jobs will require STEM skills. We work with schools in our communities to organize activities and develop curricula. We want to ensure that understanding techology become a basic skill for our next generation. Giving children the resources and empowering them to understand even the basics of sciences would open up so many options and opportunities for them down the road. Come and help to open doors to STEM for our children!",
    "address": "1501 STEM",
    "contactNumber": "8574639353",
    "contactEmail": "stem@stemresearch.com"
}')

echo "Transaction ID is $TRX_ID"

echo 'Checking that the data has been loaded'

echo 'Query all STAMPs'
echo
curl -s -X GET http://${ENDPOINT}:${PORT}/stamps -H 'content-type: application/json'
echo
echo 'Query specific STAMPs - looking for STAMP 1103'
echo
curl -s -X GET http://${ENDPOINT}:${PORT}/stamps/1103 -H 'content-type: application/json'

echo '---------------------------------------'
echo Rating
echo '---------------------------------------'
echo 'Create Rating'
echo
RATING1=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/ratings -H 'content-type: application/json' -d '{ 
   "donorUserName": "'"${DONOR1}"'", 
   "stampRegistrationNumber": "1103", 
   "rating": 4
}')
echo "Transaction ID is $TRX_ID"
echo
RATING2=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/ratings -H 'content-type: application/json' -d '{ 
   "donorUserName": "'"${DONOR2}"'", 
   "stampRegistrationNumber": "1101", 
   "rating": 5
}')
echo "Transaction ID is $TRX_ID"
echo
RATING3=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/ratings -H 'content-type: application/json' -d '{ 
   "donorUserName": "'"${DONOR2}"'", 
   "stampRegistrationNumber": "1105", 
   "rating": 3
}')
echo "Transaction ID is $TRX_ID"

echo '---------------------------------------'
echo Donors
echo '---------------------------------------'
echo 'Create Donor'
echo
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/donors -H 'content-type: application/json' -d '{ 
   "donorUserName": "jane", 
   "email": "jane@abc.com", 
   "registeredDate": "2018-10-21T09:52:20.182Z" 
}')
echo "Transaction ID is $TRX_ID"
echo
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/donors -H 'content-type: application/json' -d '{ 
   "donorUserName": "louisa", 
   "email": "louisa@hij.com", 
   "registeredDate": "2018-11-18T05:32:20.182Z" 
}')
echo "Transaction ID is $TRX_ID"

echo 'Query all donors'
echo
curl -s -X GET http://${ENDPOINT}:${PORT}/donors -H 'content-type: application/json'

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
        "donorUserName": "edge",
        "stampRegistrationNumber": "1102"
}')
echo "Transaction ID is $TRX_ID"
echo
DONATION2=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/donations -H 'content-type: application/json' -d '{ 
        "donationId": "'"${DONATION2}"'",
        "donationAmount": 255,
        "donationDate": "2020-02-18T07:41:59.582Z",
        "donorUserName": "jane",
        "stampRegistrationNumber": "1105"
}')
echo "Transaction ID is $TRX_ID"
echo
DONATION3=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/donations -H 'content-type: application/json' -d '{ 
        "donationId": "'"${DONATION3}"'",
        "donationAmount": 900,
        "donationDate": "2020-02-09T06:32:59.582Z",
        "donorUserName": "louisa",
        "stampRegistrationNumber": "1103"
}')
echo "Transaction ID is $TRX_ID"
echo
DONATION4=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/donations -H 'content-type: application/json' -d '{ 
        "donationId": "'"${DONATION4}"'",
        "donationAmount": 430,
        "donationDate": "2018-08-09T09:32:59.582Z",
        "donorUserName": "braendle",
        "stampRegistrationNumber": "1103"
}')
echo "Transaction ID is $TRX_ID"
echo
DONATION5=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/donations -H 'content-type: application/json' -d '{ 
        "donationId": "'"${DONATION5}"'",
        "donationAmount": 200,
        "donationDate": "2020-02-18T07:41:59.582Z",
        "donorUserName": "edge",
        "stampRegistrationNumber": "1103"
}')
echo "Transaction ID is $TRX_ID"
echo
DONATION6=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/donations -H 'content-type: application/json' -d '{ 
        "donationId": "'"${DONATION6}"'",
        "donationAmount": 520,
        "donationDate": "2020-02-20T12:41:59.582Z",
        "donorUserName": "edge",
        "stampRegistrationNumber": "1101"
}')
echo "Transaction ID is $TRX_ID"
echo
DONATION7=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/donations -H 'content-type: application/json' -d '{ 
        "donationId": "'"${DONATION7}"'",
        "donationAmount": 760,
        "donationDate": "2020-02-18T07:41:59.582Z",
        "donorUserName": "jane",
        "stampRegistrationNumber": "1105"
}')
echo "Transaction ID is $TRX_ID"
echo
DONATION8=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/donations -H 'content-type: application/json' -d '{ 
        "donationId": "'"${DONATION8}"'",
        "donationAmount": 25,
        "donationDate": "2020-02-09T06:32:59.582Z",
        "donorUserName": "louisa",
        "stampRegistrationNumber": "1101"
}')
echo "Transaction ID is $TRX_ID"
echo
DONATION9=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/donations -H 'content-type: application/json' -d '{ 
        "donationId": "'"${DONATION9}"'",
        "donationAmount": 44,
        "donationDate": "2018-08-09T09:32:59.582Z",
        "donorUserName": "braendle",
        "stampRegistrationNumber": "1103"
}')
echo "Transaction ID is $TRX_ID"
echo
DONATION10=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/donations -H 'content-type: application/json' -d '{ 
        "donationId": "'"${DONATION10}"'",
        "donationAmount": 120,
        "donationDate": "2020-02-18T07:41:59.582Z",
        "donorUserName": "edge",
        "stampRegistrationNumber": "1104"
}')
echo "Transaction ID is $TRX_ID"

echo 'Query all Donations'
echo
curl -s -X GET http://${ENDPOINT}:${PORT}/donations -H 'content-type: application/json'

echo '---------------------------------------'
echo Stamp
echo '---------------------------------------'
echo 'Create Stamp'
echo
SPENDID=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/stamp -H 'content-type: application/json' -d '{ 
        "stampRegistrationNumber": "1103",
        "stampId": "'"${SPENDID}"'",
        "stampDescription": "Fees for hiring transport for animal delivery",
        "stampDate": "2018-11-19T12:20:59.582Z",
        "stampAmount": 125
}')
echo "Transaction ID is $TRX_ID"
echo
SPENDID=$(uuidgen)
TRX_ID=$(curl -s -X POST http://${ENDPOINT}:${PORT}/stamp -H 'content-type: application/json' -d '{ 
        "stampRegistrationNumber": "1105",
        "stampId": "'"${SPENDID}"'",
        "stampDescription": "Purchase test tubes",
        "stampDate": "2020-02-10T22:41:59.582Z",
        "stampAmount": 99
}')
echo "Transaction ID is $TRX_ID"
