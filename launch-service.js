var fs = require('fs');
var https = require('https');

var images = {
    // image type -> image name
    "sigma-ubuntu": "lightvm",
    "sigma-ubuntu-redis": "redis-sdk",
    "sigma-ubuntu-nodejs": "nodejs-sdk",
    "sigma-ubuntu-golang": "golang-sdk",
    "sigma-ubuntu-demo-web-redis-app": "demo-web-redis-app"
};

var unique_name = "vm-" + process.env.BUILD_USER_ID + "-" + process.env.SERVICE_NAME;
var post_data = fs.readFileSync('lightvm-controller.json', 'utf8');
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

var req = https.request(options, function (res) {
    if (res.statusCode != 201) {
        res.on('data', function (chunk) {
            var status = JSON.parse(chunk);
            console.log('Failed: ' + status.message);
            checkStatus(unique_name, null, true, status.message);
        });
    } else {
        res.on('data', function (chunk) {
            var obj = JSON.parse(chunk);
            console.log('Created: current replicas = ' + obj.status.replicas);
            var count = 0;
            var timer = setInterval(function () {
                count++;
                if (count > 30) {
                    clearInterval(timer);
                    console.log('Timeout: check with sigma admin for details.');
                    checkStatus(obj.metadata.name, null, true, "Timeout");
                }
                checkStatus(obj.metadata.name, timer, false, null);
            }, 1000);
        });
    }
});
req.on('error', function (e) {
    throw e;
});
req.write(post_data);
req.end();

function checkStatus(name, timer, showStatusAndExit, exitReason) {
    var options = {
        hostname: '61.160.36.122',
        port: 443,
        path: '/api/v1/namespaces/default/replicationcontrollers/' + name,
        method: 'GET',
        auth: 'test:test123',
        rejectUnauthorized: false
    };
    var req = https.request(options, function (res) {
        if (res.statusCode != 200) {
            res.on('data', function (chunk) {
                var status = JSON.parse(chunk);
                throw new Error(status.message);
            });
        }
        res.on('data', function (chunk) {
            var obj = JSON.parse(chunk);
            console.log('Checking: current replicas = ' + obj.status.replicas);
            if (showStatusAndExit) {
                console.log(JSON.stringify(obj.status, null, 2));
                throw new Error('Failed to launch: ' + exitReason);
            }
            if (obj.status.replicas == requiredReplicas) {
                if (timer) {
                    clearInterval(timer);
                }
                console.log('Done: next is to do service discovery with service name: ' + process.env.SERVICE_NAME);
            }
        });
    });
    req.end();
}
