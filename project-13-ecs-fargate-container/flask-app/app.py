"""
Project 13 — Flask application for ECS Fargate deployment.
Demonstrates containerized web app with health check endpoint.
"""

from flask import Flask, jsonify, request
import os
import socket
import datetime
import platform

app = Flask(__name__)

# ── HOME ROUTE ───────────────────────────────────────────────────────
@app.route('/')
def home():
    return f"""
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Flask on ECS Fargate</title>
  <style>
    * {{ box-sizing: border-box; margin: 0; padding: 0; }}
    body {{
      font-family: Arial, sans-serif;
      background: linear-gradient(135deg, #232f3e 0%, #1a73e8 100%);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
    }}
    .card {{
      background: white;
      border-radius: 16px;
      padding: 40px;
      max-width: 600px;
      width: 90%;
      box-shadow: 0 20px 60px rgba(0,0,0,0.3);
    }}
    .badge {{
      background: #ff9900;
      color: white;
      padding: 6px 16px;
      border-radius: 20px;
      font-size: 13px;
      display: inline-block;
      margin-bottom: 20px;
    }}
    h1 {{ color: #232f3e; margin-bottom: 20px; font-size: 26px; }}
    .info {{
      background: #f0f7ff;
      border-radius: 8px;
      padding: 14px;
      margin: 10px 0;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }}
    .label {{ font-size: 12px; color: #888; text-transform: uppercase; }}
    .value {{ font-size: 15px; font-weight: bold; color: #232f3e; }}
    .healthy {{
      background: #d4edda;
      color: #155724;
      border-radius: 8px;
      padding: 12px;
      margin-top: 20px;
      text-align: center;
      font-weight: bold;
    }}
    .version {{
      text-align: center;
      color: #888;
      font-size: 12px;
      margin-top: 16px;
    }}
  </style>
</head>
<body>
  <div class="card">
    <span class="badge">Running on ECS Fargate — Project 13</span>
    <h1>🐳 Flask App on AWS Fargate</h1>

    <div class="info">
      <div>
        <div class="label">Hostname (Container ID)</div>
        <div class="value">{socket.gethostname()}</div>
      </div>
    </div>

    <div class="info">
      <div>
        <div class="label">Python Version</div>
        <div class="value">{platform.python_version()}</div>
      </div>
    </div>

    <div class="info">
      <div>
        <div class="label">Region</div>
        <div class="value">{os.environ.get('AWS_REGION', 'ap-south-1')}</div>
      </div>
    </div>

    <div class="info">
      <div>
        <div class="label">Environment</div>
        <div class="value">{os.environ.get('ENVIRONMENT', 'production')}</div>
      </div>
    </div>

    <div class="info">
      <div>
        <div class="label">Server Time (UTC)</div>
        <div class="value">{datetime.datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')}</div>
      </div>
    </div>

    <div class="healthy">
      ✅ Container Healthy — Serving Traffic via ALB
    </div>
    <div class="version">Version 2.0 | ECS Fargate | ap-south-1</div>
  </div>
</body>
</html>
"""

# ── HEALTH CHECK ─────────────────────────────────────────────────────
@app.route('/health')
def health():
    """ALB health check endpoint."""
    return jsonify({
        'status':    'healthy',
        'hostname':  socket.gethostname(),
        'timestamp': datetime.datetime.utcnow().isoformat(),
        'version':   '1.0'
    }), 200

# ── API INFO ─────────────────────────────────────────────────────────
@app.route('/api/info')
def info():
    """Returns container and environment information."""
    return jsonify({
        'app':       'flask-fargate-demo',
        'version':   '1.0',
        'hostname':  socket.gethostname(),
        'region':    os.environ.get('AWS_REGION', 'ap-south-1'),
        'env':       os.environ.get('ENVIRONMENT', 'production'),
        'python':    platform.python_version(),
        'timestamp': datetime.datetime.utcnow().isoformat()
    })

# ── ENTRY POINT ──────────────────────────────────────────────────────
if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)
