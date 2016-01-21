#!/usr/bin/env python3

from http.server import HTTPServer
from http.server import BaseHTTPRequestHandler
import os
import subprocess
from datetime import datetime

PORT = 80
REDIS_BACKEND = os.environ['REDIS_BACKEND']
local_counter = 0

class MyHandler(BaseHTTPRequestHandler):
	def do_GET(self):
		output = subprocess.check_output([
				"/usr/src/redis/src/redis-trib.rb",
				"info",
				REDIS_BACKEND
			], universal_newlines=True)
		counter = subprocess.check_output([
				"redis-cli",
				"-h", REDIS_BACKEND.split(':')[0],
				"-p", REDIS_BACKEND.split(':')[1],
				"INCR", "hit"
			], universal_newlines=True)
		global local_counter
		local_counter += 1
		self.send_response(200)
		self.send_header("Content-type", "text/plain")
		self.end_headers()
		self.wfile.write(bytes('CLIENT_ADDR: %r\n' % (repr(self.client_address)), 'utf-8'))
		self.wfile.write(bytes('SERVER_TIME: %s\n' % (datetime.now().strftime('%Y-%m-%d %H:%M:%S')), 'utf-8'))
		self.wfile.write(bytes(output, 'utf-8'))
		self.wfile.write(bytes('HIT COUNTER: %s' % (counter), 'utf-8'))
		self.wfile.write(bytes('LOCAL COUNTER: %d\n' % (local_counter), 'utf-8'))

HTTPServer(('', PORT), MyHandler).serve_forever()
