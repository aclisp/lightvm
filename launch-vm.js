var fs = require('fs');
var https = require('https');

var images = {
    // image type -> image name
    "sigma+ubuntu": "lightvm",
    "sigma+ubuntu+redis": "redis-sdk",
    "sigma+ubuntu+nodejs": "nodejs-sdk",
    "sigma+ubuntu+golang": "golang-sdk"
};

var unique_name = "lightvm-" + process.env.TARGET_IP.replace(/\./g, "-") + "-" + process.env.BUILD_NUMBER;
var post_data = fs.readFileSync('lightvm.json', 'utf8');
post_data = post_data
    .replace(/@REGISTRY@/g, "61.160.36.122:8080")
    .replace(/@IMAGE_TYPE@/g, process.env.IMAGE)
    .replace(/@IMAGE_NAME@/g, images[process.env.IMAGE])
    .replace(/@IMAGE_VERSION@/g, process.env.IMAGE_VERSION)
    .replace(/@SSH_PORT@/g, process.env.SSH_PORT)
    .replace(/@CPU_CORE@/g, process.env.CPU_CORE)
    .replace(/@MEMORY_G@/g, process.env.MEMORY_G)
    .replace(/@SSH_PUBLIC_KEY@/g, process.env.SSH_PUBLIC_KEY)
    .replace(/@TARGET_IP@/g, process.env.TARGET_IP)
    .replace(/@UNIQUE_NAME@/g, unique_name)
    .replace(/@USER@/g, process.env.BUILD_USER_ID)
    .replace(/@DAEMON_MONITOR@/g, "");
console.log("Data: " + post_data);

var options = {
    hostname: '61.160.36.122',
    port: 443,
    path: '/api/v1/namespaces/default/pods',
    method: 'POST',
    auth: 'test:test123',
    rejectUnauthorized: false
};

var req = https.request(options, function (res) {
    if (res.statusCode != 201) {
        res.on('data', function (chunk) {
            var status = JSON.parse(chunk);
            console.log('Failed: ' + status.message);
            checkPod(unique_name, null, true, status.message);
        });
    }
    res.on('data', function (chunk) {
        var pod = JSON.parse(chunk);
        console.log('Created: phase = ' + pod.status.phase);
        var count = 0;
        var timer = setInterval(function () {
            count++;
            if (count > 30) {
                clearInterval(timer);
                console.log('Timeout: check with sigma admin for details.');
                checkPod(pod.metadata.name, null, true, "Timeout");
            }
            checkPod(pod.metadata.name, timer, false, null);
        }, 1000);
    });
});
req.on('error', function (e) {
    throw e;
});
req.write(post_data);
req.end();

function checkPod(name, timer, showStatusAndExit, exitReason) {
    var options = {
        hostname: '61.160.36.122',
        port: 443,
        path: '/api/v1/namespaces/default/pods/' + name,
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
            var pod = JSON.parse(chunk);
            console.log('Checking: phase = ' + pod.status.phase);
            if (showStatusAndExit) {
                console.log(JSON.stringify(pod.status, null, 2));
                throw new Error('Failed to launch: ' + exitReason);
            }
            if (pod.status.phase == "Running") {
                if (timer) {
                    clearInterval(timer);
                }
                console.log('Info: ' + pod.status.message);
                var portMappings = /PortMapping\((.*)\)/.exec(pod.status.message)[1].split(",");
                var hostSSHPort;
                for (var i in portMappings) {
                    var pm = portMappings[i].split("->");
                    var hostPort = pm[0];
                    var containerPort = pm[1];
                    if (containerPort == '22') {
                        hostSSHPort = hostPort;
                    }
                }
                console.log('Done: go to container with "ssh -p ' + hostSSHPort + ' root@' + process.env.TARGET_IP);
            }
        });
    });
    req.end();
}
