var https = require('https');
var querystring = require('querystring');

var unique_name = "vm-" + process.env.BUILD_USER_ID + "-" + process.env.SERVICE_NAME;
var query = {
    labelSelector: "user=" + process.env.BUILD_USER_ID + "," +
                   "name=" + unique_name
};

var options = {
    hostname: '61.160.36.122',
    port: 443,
    path: '/api/v1/namespaces/default/pods?' + querystring.stringify(query),
    method: 'GET',
    auth: 'test:test123',
    rejectUnauthorized: false
};
console.log(options.path);
var req = https.request(options, function (res) {
    if (res.statusCode != 200) {
        res.on('data', function (chunk) {
            var status = JSON.parse(chunk);
            throw new Error(status.message);
        });
    }
    var body = '';
    res.on('data', function (chunk) {
        body += chunk;
    });
    res.on('end', function () {
        var obj = JSON.parse(body);
        //console.log(JSON.stringify(obj, null, 2));
        console.log([
                "INSTANCE",
                "TYPE",
                "VERSION",
                "STATUS",
                "HOST",
                "PORT"
            ].join('\t'));
        for (var i in obj.items) {
            var pod = obj.items[i];
            console.log([
                pod.metadata.name,
                pod.metadata.labels.type,
                pod.metadata.labels.version,
                pod.status.phase,
                pod.status.hostIP,
                pod.status.message].join('\t'));
        }
    });
});
req.end();
