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
    res.on('data', function (chunk) {
        var obj = JSON.parse(chunk);
        console.log(obj);
    });
});
req.end();
