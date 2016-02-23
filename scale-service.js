var https = require('https');
var rc = require('./rc-requestor.js');

var unique_name = process.env.BUILD_USER_ID + "-" + process.env.SERVICE_NAME;

var options = {
    hostname: '61.160.36.122',
    port: 443,
    path: '/api/v1/namespaces/default/replicationcontrollers/' + unique_name,
    method: 'PATCH',
    headers: {
    	'Content-Type': 'application/strategic-merge-patch+json'
    },
    auth: 'test:test123',
    rejectUnauthorized: false
};
var requiredReplicas = parseInt(process.env.REPLICAS, 10);
var post_obj = {
	spec: {
		replicas: requiredReplicas
	}
};
var post_data = JSON.stringify(post_obj, null, 2);
console.log("Query: " + options.path);
console.log("Request: " + post_data);

rc.requestAndCheck(unique_name, options, post_data, requiredReplicas);
