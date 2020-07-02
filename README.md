## Building and deploying an Time Stamping Service for Hyperledger Fabric

This project builds and deploy a 2-tier application that uses the Fabric network to provide a Time Stamping Service. 

The 2-tier application consists of the following components:

* RESTful API, running as a Node.js Express application, using the Hyperledger Fabric Client SDK to query 
and invoke chaincode
* Fabric Chaincode, written in Node.js, deployed to a Hyperledger Fabric network

## Getting started

To deploy the chaincode and start the RESTful API server, follow the 
README instructions in parts 1-2, in this order:

* [Part 1:](chaincode/README.md) Deploy the chaincode. 
* [Part 2:](rest-api/README.md) Run the RESTful API server. 

## License

This library is licensed under the Apache 2.0 License. 
