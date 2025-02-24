from flask import Flask, render_template_string
import os

app = Flask(__name__)

HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title>AdvancedSpy Status</title>
    <style>
        body { 
            font-family: Arial, sans-serif;
            margin: 40px;
            background: #2C3E50;
            color: white;
        }
        .status-box {
            background: #34495E;
            padding: 20px;
            border-radius: 8px;
            max-width: 600px;
            margin: 0 auto;
        }
        h1 { color: #3498DB; }
        .feature { margin: 10px 0; }
        code {
            background: #2C3E50;
            padding: 10px;
            display: block;
            margin: 10px 0;
            border-radius: 4px;
            white-space: pre-wrap;
        }
    </style>
</head>
<body>
    <div class="status-box">
        <h1>AdvancedSpy Status</h1>
        <div class="feature">✅ Remote Event Interception Ready</div>
        <div class="feature">✅ Mobile-friendly UI Active</div>
        <div class="feature">✅ Script Generation Available</div>
        <div class="feature">✅ Network Visualization Ready</div>
        <p style="margin-top: 20px;">
            Load AdvancedSpy in Roblox using:<br>
            <code>loadstring(game:HttpGet("https://raw.githubusercontent.com/YourUsername/AdvancedSpy/main/AdvancedSpy.lua"))()</code>
        </p>
        <p>
            Features:
            <ul>
                <li>Remote event and function interception</li>
                <li>Mobile-friendly touch controls</li>
                <li>Dark/Light theme support</li>
                <li>Advanced script generation</li>
                <li>Network traffic analysis</li>
            </ul>
        </p>
    </div>
</body>
</html>
"""

@app.route('/')
def status():
    return render_template_string(HTML_TEMPLATE)

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)