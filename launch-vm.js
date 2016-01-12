const fs = require('fs');
const https = require('https');

var post_data = fs.readFileSync('lightvm.json', 'utf8');
post_data = post_data
    .replace(/@REGISTRY@/g, "61.160.36.122:8080")
    .replace(/@IMAGE_NAME@/g, process.env.IMAGE_NAME)
    .replace(/@IMAGE_VERSION@/g, process.env.IMAGE_VERSION)
    .replace(/@SSH_PORT@/g, process.env.SSH_PORT)
    .replace(/@CPU_CORE@/g, process.env.CPU_CORE)
    .replace(/@MEMORY_G@/g, process.env.MEMORY_G)
    .replace(/@SSH_PUBLIC_KEY@/g, process.env.SSH_PUBLIC_KEY)
    .replace(/@TARGET_IP@/g, process.env.TARGET_IP)
    .replace(/@UNIQUE_NAME@/g, "lightvm-" + process.env.TARGET_IP.replace(/\./g, "-") + "-" + process.env.SSH_PORT)
    .replace(/@DAEMON_MONITOR@/g, "")
console.log("TX: " + post_data)

var options = {
    hostname: '61.160.36.122',
    port: 443,
    path: '/api/v1/namespaces/default/pods',
    method: 'POST',
    auth: 'test:test123'
};

var req = https.request(options, (res) => {
    console.log('STATUS_CODE: ', res.statusCode);
    console.log('HEADERS: ', res.headers);
    res.on('data', (chunk) => {
        console.log(`BODY: ${chunk}`);
    });
    res.on('end', () => {
        console.log('END: No more data in response.')
    })
})
req.on('error', (e) => {
    console.log(`ERROR: Problem with request: ${e.message}`);
});
req.write(post_data);
req.end();
