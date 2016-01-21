var https = require('https');

exports.requestAndCheck = requestAndCheck;

function requestAndCheck(unique_name, options, post_data, requiredReplicas) {
    var req = https.request(options, function (res) {
        if (res.statusCode != 201) {
            res.on('data', function (chunk) {
                var status = JSON.parse(chunk);
                console.log('Failed: ' + status.message);
                checkStatus(unique_name, null, true, status.message, requiredReplicas);
            });
        } else {
            res.on('data', function (chunk) {
                var obj = JSON.parse(chunk);
                console.log('Confirmed: current replicas = ' + obj.status.replicas);
                var count = 0;
                var timer = setInterval(function () {
                    count++;
                    if (count > 30) {
                        clearInterval(timer);
                        console.log('Timeout: check with sigma admin for details.');
                        checkStatus(obj.metadata.name, null, true, "Timeout", requiredReplicas);
                    }
                    checkStatus(obj.metadata.name, timer, false, null, requiredReplicas);
                }, 1000);
            });
        }
    });
    req.on('error', function (e) {
        throw e;
    });
    req.write(post_data);
    req.end();
}

function checkStatus(name, timer, showStatusAndExit, exitReason, requiredReplicas) {
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
