from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
from pathlib import Path
import os
os.chdir(Path(__file__).resolve().parents[1] / 'public')
ThreadingHTTPServer(('127.0.0.1', 8008), SimpleHTTPRequestHandler).serve_forever()
