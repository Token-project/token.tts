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


function installNodeModules() {
	echo
	if [ -d node_modules ]; then
		echo "============== node modules installed already ============="
	else
		echo "============== Installing node modules ============="
		npm install
	fi
	echo
}


# Clears the key stores before starting the Node app

rm -rf /tmp/fabric-client-kv-org1/
rm -rf fabric-client-kv-org1/
rm -rf /tmp/fabric-client-kv-org2/
rm -rf fabric-client-kv-org2/
installNodeModules
node app.js 