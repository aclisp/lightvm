var fs = require('fs');

var req = fs.readFileSync('lightvm.json', 'utf8');

req.replace(/@REGISTRY@/g, "61.160.36.122:8080")
    .replace(/@IMAGE_NAME@/g, process.env.IMAGE_NAME)
    .replace(/@IMAGE_VERSION@/g, process.env.IMAGE_VERSION)
    .replace(/@SSH_PORT@/g, process.env.SSH_PORT)
    .replace(/@CPU_CORE@/g, process.env.CPU_CORE)
    .replace(/@MEMORY_G@/g, process.env.MEMORY_G)
    .replace(/@SSH_PUBLIC_KEY@/g, process.env.SSH_PUBLIC_KEY)
    .replace(/@TARGET_IP@/g, process.env.TARGET_IP)

console.log(req)
