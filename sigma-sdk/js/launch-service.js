var fs = require('fs');
var https = require('https');
var rc = require('./rc-requestor.js');

var images = {
    // image type -> image name
    "sigma-ubuntu": "lightvm",
    "sigma-ubuntu-redis": "redis-sdk",
    "sigma-ubuntu-nodejs": "nodejs-sdk",
    "sigma-ubuntu-golang": "golang-sdk",
    "sigma-ubuntu-demo-web-redis-app": "demo-web-redis-app",
    "mysql": "mysql"
};

var unique_name = process.env.BUILD_USER_ID + "-" + process.env.SERVICE_NAME;
var post_data = fs.readFileSync(process.env.SERVICE_SPEC, 'utf8');
post_data = post_data
    .replace(/@REGISTRY@/g, "61.160.36.122:8080")
    .replace(/@IMAGE_TYPE@/g, process.env.IMAGE)
    .replace(/@IMAGE_NAME@/g, images[process.env.IMAGE])
    .replace(/@IMAGE_VERSION@/g, process.env.IMAGE_VERSION)
    .replace(/@CPU_CORE@/g, process.env.CPU_CORE)
    .replace(/@MEMORY_G@/g, process.env.MEMORY_G)
    .replace(/@SSH_PUBLIC_KEY@/g, process.env.SSH_PUBLIC_KEY)
    .replace(/@TARGET_REGION@/g, process.env.TARGET_REGION)
    .replace(/@UNIQUE_NAME@/g, unique_name)
    .replace(/@USER@/g, process.env.BUILD_USER_ID)
    .replace(/@DAEMON_MONITOR@/g, "");

var post_obj = JSON.parse(post_data);
var requiredReplicas = parseInt(process.env.REPLICAS, 10);
post_obj.spec.replicas = requiredReplicas;
post_data = JSON.stringify(post_obj, null, 2);
console.log("Request: " + post_data);

var options = {
    hostname: '61.160.36.122',
    port: 443,
    path: '/api/v1/namespaces/default/replicationcontrollers',
    method: 'POST',
    auth: 'test:test123',
    rejectUnauthorized: false
};

rc.requestAndCheck(unique_name, options, post_data, requiredReplicas);
