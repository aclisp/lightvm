#!/usr/bin/env python3

from http.server import HTTPServer
from http.server import BaseHTTPRequestHandler
import os
import subprocess

PORT = 80
REDIS_BACKEND = os.environ['REDIS_BACKEND']

class MyHandler(BaseHTTPRequestHandler):
	def do_GET(self):
		output = subprocess.check_output([
				"/usr/src/redis/src/redis-trib.rb",
				"check",
				REDIS_BACKEND
			], universal_newlines=True)
		self.send_response(200)
		self.send_header("Content-type", "text/plain")
		self.end_headers()
		self.wfile.write(output)

HTTPServer(('', PORT), MyHandler).serve_forever()
