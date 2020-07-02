/*
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
*/

'use strict';
var log4js = require('log4js');
log4js.configure({
	appenders: {
		out: {
			type: 'stdout'
		},
	},
	categories: {
		default: {
			appenders: ['out'],
			level: 'info'
		},
	}
});
var logger = log4js.getLogger('TTSAPI');
const WebSocketServer = require('ws');
var express = require('express');
var session = require('express-session');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var http = require('http');
var util = require('util');
var app = express();
var expressJWT = require('express-jwt');
var jwt = require('jsonwebtoken');
var bearerToken = require('express-bearer-token');
var cors = require('cors');
var hfc = require('fabric-client');
const uuidv4 = require('uuid/v4');

var connection = require('./connection.js');
var query = require('./query.js');
var invoke = require('./invoke.js');
var blockListener = require('./blocklistener.js');

hfc.addConfigFile('config.json');
var host = 'localhost';
var port = 3000;
var channelName = hfc.getConfigSetting('channelName');
var chaincodeName = hfc.getConfigSetting('chaincodeName');
var peers = hfc.getConfigSetting('peers');
///////////////////////////////////////////////////////////////////////////////
//////////////////////////////// SET CONFIGURATONS ////////////////////////////
///////////////////////////////////////////////////////////////////////////////
app.options('*', cors());
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({
	extended: false
}));
// set secret variable
app.set('secret', 'jwtsecret');
app.use(expressJWT({
	secret: 'jwtsecret'
}).unless({
	path: ['/users', '/health']
}));
app.use(bearerToken());
app.use(function (req, res, next) {
	logger.info(' ##### New request for URL %s', req.originalUrl);
	if (req.originalUrl.indexOf('/users') >= 0 || req.originalUrl.indexOf('/health') >= 0) {
		return next();
	}

	var token = req.token;
	jwt.verify(token, app.get('secret'), function (err, decoded) {
		if (err) {
			res.send({
				success: false,
				message: 'Failed to authenticate token. Make sure to include the ' +
					'token returned from /users call in the authorization header ' +
					' as a Bearer token'
			});
			return;
		} else {
			// add the decoded user name and org name to the request object
			// for the downstream code to use
			req.username = decoded.username;
			req.orgname = decoded.orgName;
			logger.debug(util.format('Decoded from JWT token: username - %s, orgname - %s', decoded.username, decoded.orgName));
			return next();
		}
	});
});

//wrapper to handle errors thrown by async functions. We can catch all
//errors thrown by async functions in a single place, here in this function,
//rather than having a try-catch in every function below. The 'next' statement
//used here will invoke the error handler function - see the end of this script
const awaitHandler = (fn) => {
	return async (req, res, next) => {
		try {
			await fn(req, res, next)
		} catch (err) {
			next(err)
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
//////////////////////////////// START SERVER /////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
var server = http.createServer(app).listen(port, function () {});
logger.info('****************** SERVER STARTED ************************');
logger.info('***************  Listening on: http://%s:%s  ******************', host, port);
server.timeout = 240000;

function getErrorMessage(field) {
	var response = {
		success: false,
		message: field + ' field is missing or Invalid in the request'
	};
	return response;
}

///////////////////////////////////////////////////////////////////////////////
//////////////////////////////// START WEBSOCKET SERVER ///////////////////////
///////////////////////////////////////////////////////////////////////////////
const wss = new WebSocketServer.Server({
	server
});
wss.on('connection', function connection(ws) {
	logger.info('****************** WEBSOCKET SERVER - received connection ************************');
	ws.on('message', function incoming(message) {
		console.log('##### Websocket Server received message: %s', message);
	});

	ws.send('something');
});

///////////////////////////////////////////////////////////////////////////////
///////////////////////// REST ENDPOINTS START HERE ///////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Health check - can be called by load balancer to check health of REST API
app.get('/health', awaitHandler(async (req, res) => {
	res.sendStatus(200);
}));

// Register and enroll user. A user must be registered and enrolled before any queries 
// or transactions can be invoked
app.post('/users', awaitHandler(async (req, res) => {
	logger.info('================ POST on Users');
	var username = req.body.username;
	var orgName = req.body.orgName;
	if (!username) {
		res.json(getErrorMessage('\'username\''));
		return;
	}
	if (!orgName) {
		res.json(getErrorMessage('\'orgName\''));
		return;
	}
	logger.info('##### End point : /users');
	logger.info('##### POST on Users- username : ' + username);
	logger.info('##### POST on Users - userorg  : ' + orgName);
	var token = jwt.sign({
		exp: Math.floor(Date.now() / 1000) + parseInt(hfc.getConfigSetting('jwt_expiretime')),
		username: username,
		orgName: orgName
	}, app.get('secret'));
	let response = await connection.getRegisteredUser(username, orgName, true);
	logger.info('##### POST on Users - returned from registering the username %s for organization %s', username, orgName);
	logger.info('##### POST on Users - getRegisteredUser response secret %s', response.secret);
	logger.info('##### POST on Users - getRegisteredUser response secret %s', response.message);
	if (response && typeof response !== 'string') {
		logger.info('##### POST on Users - Successfully registered the username %s for organization %s', username, orgName);
		logger.info('##### POST on Users - getRegisteredUser response %s', response);
		// Now that we have a username & org, we can start the block listener
		await blockListener.startBlockListener(channelName, username, orgName, wss);
		response.token = token;
		res.json(response);
	} else {
		logger.error('##### POST on Users - Failed to register the username %s for organization %s with::%s', username, orgName, response);
		res.json({
			success: false,
			message: response
		});
	}
}));

/************************************************************************************
 * Stamp methods
 ************************************************************************************/

// GET Stamp
app.get('/stamps', awaitHandler(async (req, res) => {
	logger.info('================ GET on Stamp');
	let args = {};
	let fcn = "queryAllStamp";

	logger.info('##### GET on Stamp - username : ' + req.user.username);
	logger.info('##### GET on Stamp - userOrg : ' + req.user.orgName);
	logger.info('##### GET on Stamp - channelName : ' + channelName);
	logger.info('##### GET on Stamp - chaincodeName : ' + chaincodeName);
	logger.info('##### GET on Stamp - fcn : ' + fcn);
	logger.info('##### GET on Stamp - args : ' + JSON.stringify(args));
	logger.info('##### GET on Stamp - peers : ' + peers);

	let message = await query.queryChaincode(peers, channelName, chaincodeName, args, fcn, req.user.username, req.user.orgName);
	res.send(message);
}));

// GET a specific Stamp
app.get('/stamp/:hash', awaitHandler(async (req, res) => {
	logger.info('================ GET on Stamp by hash');
	logger.info('Stamp hash : ' + req.params.hash);
	let args = req.params;
	let fcn = "queryStamp";

	logger.info('##### GET on Stamp - username : ' + req.user.username);
	logger.info('##### GET on Stamp - userOrg : ' + req.user.orgName);
	logger.info('##### GET on Stamp - channelName : ' + channelName);
	logger.info('##### GET on Stamp - chaincodeName : ' + chaincodeName);
	logger.info('##### GET on Stamp - fcn : ' + fcn);
	logger.info('##### GET on Stamp - args : ' + JSON.stringify(args));
	logger.info('##### GET on Stamp - peers : ' + peers);

	if (!req.params.hash) {
		res.json(getErrorMessage('\'hash\''));
		return;
	}

	let message = await query.queryChaincode(peers, channelName, chaincodeName, args, fcn, req.user.username, req.user.orgName);
	res.send(message);
}));

// GET all UID stamps
app.get('/stamps/uid/:uid', awaitHandler(async (req, res) => {
	logger.info('================ GET on Stamps by uid');
	logger.info('Stamp uid : ' + req.params.uid);
	let args = req.params;
	let fcn = "queryStampForUID";

	logger.info('##### GET on Stamp - username : ' + req.user.username);
	logger.info('##### GET on Stamp - userOrg : ' + req.user.orgName);
	logger.info('##### GET on Stamp - channelName : ' + channelName);
	logger.info('##### GET on Stamp - chaincodeName : ' + chaincodeName);
	logger.info('##### GET on Stamp - fcn : ' + fcn);
	logger.info('##### GET on Stamp - args : ' + JSON.stringify(args));
	logger.info('##### GET on Stamp - peers : ' + peers);

	if (!req.params.uid) {
		res.json(getErrorMessage('\'uid\''));
		return;
	}

	let message = await query.queryChaincode(peers, channelName, chaincodeName, args, fcn, req.user.username, req.user.orgName);
	res.send(message);
}));

// POST Stamp
app.post('/stamp', awaitHandler(async (req, res) => {
	logger.info('================ POST Stamp');
	var args = req.body;
	var fcn = "createStamp";
	logger.info('##### POST Stamp - username : ' + req.user.username);
	logger.info('##### POST Stamp - userOrg : ' + req.user.orgName);
	logger.info('##### POST Stamp - channelName : ' + channelName);
	logger.info('##### POST Stamp - chaincodeName : ' + chaincodeName);
	logger.info('##### POST Stamp - fcn : ' + fcn);
	logger.info('##### POST Stamp - args : ' + JSON.stringify(args));
	logger.info('##### POST Stamp - peers : ' + peers);

	let message = await invoke.invokeChaincode(peers, channelName, chaincodeName, args, fcn, req.user.username, req.user.orgName);
	res.send(message);
}));

/************************************************************************************
 * Blockchain metadata methods
 ************************************************************************************/

// GET details of a blockchain transaction using the record key (i.e. the key used to store the transaction
// in the world state)
app.get('/blockinfos/:docType/keys/:key', awaitHandler(async (req, res) => {
	logger.info('================ GET on blockinfo');
	logger.info('Key is : ' + req.params);
	let args = req.params;
	let fcn = "queryHistoryForKey";

	logger.info('##### GET on blockinfo - username : ' + req.user.username);
	logger.info('##### GET on blockinfo - userOrg : ' + req.user.orgName);
	logger.info('##### GET on blockinfo - channelName : ' + channelName);
	logger.info('##### GET on blockinfo - chaincodeName : ' + chaincodeName);
	logger.info('##### GET on blockinfo - fcn : ' + fcn);
	logger.info('##### GET on blockinfo - args : ' + JSON.stringify(args));
	logger.info('##### GET on blockinfo - peers : ' + peers);

	let history = await query.queryChaincode(peers, channelName, chaincodeName, args, fcn, req.user.username, req.user.orgName);
	logger.info('##### GET on blockinfo - queryHistoryForKey : ' + util.inspect(history));
	res.send(history);
}));

//  Query Get Block by BlockNumber
app.get('/blockinfos/blocks/:blockId', async function (req, res) {
	logger.debug('==================== GET BLOCK BY NUMBER ==================');
	let blockId = req.params.blockId;
	logger.debug('channelName : ' + channelName);
	logger.debug('BlockID : ' + blockId);
	if (!blockId) {
		res.json(getErrorMessage('\'blockId\''));
		return;
	}

	let message = await query.getBlockByNumber(peers, channelName, blockId, req.username, req.orgname);
	res.send(message);
});
// Query Get Block by Hash
app.get('/blockinfos/blocks/hash/:blockHash', async function (req, res) {
	logger.debug('================ GET BLOCK BY HASH ======================');
	logger.debug('channelName : ' + channelName);
	let hash = req.params.blockHash;
	if (!hash) {
		res.json(getErrorMessage('\'hash\''));
		return;
	}

	let message = await query.getBlockByHash(peers[0], channelName, hash, req.username, req.orgname);
	res.send(message);
});
// Query Get Transaction by Transaction ID
app.get('/blockinfos/transactions/:trxnId', async function (req, res) {
	logger.debug('================ GET TRANSACTION BY TRANSACTION_ID ======================');
	logger.debug('channelName : ' + channelName);
	let trxnId = req.params.trxnId;
	if (!trxnId) {
		res.json(getErrorMessage('\'trxnId\''));
		return;
	}

	let message = await query.getTransactionByID(peers[0], channelName, trxnId, req.username, req.orgname);
	res.send(message);
});
/************************************************************************************
 * Error handler
 ************************************************************************************/

app.use(function (error, req, res, next) {
	res.status(500).json({
		error: error.toString()
	});
});