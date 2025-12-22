import random
import string
import os
from datetime import datetime

# 1. Yeni Rastgele Key Üret (Örn: KEY-AB12)
def generate_key():
    chars = string.ascii_uppercase + string.digits
    key = "NEXUS-" + ''.join(random.choice(chars) for _ in range(5))
    return key

new_key = generate_key()
date_str = datetime.now().strftime("%d.%m.%Y")

# 2. Scriptlerin okuyacağı dosyayı güncelle
with open("key.txt", "w") as f:
    f.write(new_key)

# 3. İnsanların Linkvertise'dan sonra göreceği siteyi güncelle
html_content = f"""
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Roblox Gaming Hub Key</title>
    <style>
        body {{ background-color: #111; color: #fff; font-family: sans-serif; display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100vh; margin: 0; }}
        .container {{ border: 2px solid #00ff00; padding: 40px; border-radius: 15px; text-align: center; box-shadow: 0 0 30px rgba(0, 255, 0, 0.3); }}
        h1 {{ color: #00ff00; }}
        .key-box {{ font-size: 50px; font-weight: bold; background: #222; padding: 20px; border-radius: 10px; margin: 20px 0; letter-spacing: 5px; }}
        p {{ color: #aaa; }}
    </style>
</head>
<body>
    <div class="container">
        <h1>🔑 GÜNLÜK KEY</h1>
        <div class="key-box">{new_key}</div>
        <p>Son Güncelleme: {date_str}</p>
        <p>Bu kodu kopyala ve Hub'a yapıştır.</p>
    </div>
</body>
</html>
"""

with open("index.html", "w") as f:
    f.write(html_content)

print(f"Key Guncellendi: {new_key}")
