#!/usr/bin/env python3
"""Generate app_icon.ico + installer wizard images from the FreelanceHub logo."""
from PIL import Image
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, 'assets', 'freelancehub_logo.png')
ICO = os.path.join(ROOT, 'windows', 'runner', 'resources', 'app_icon.ico')
BANNER = os.path.join(ROOT, 'installer', 'wizard_image.bmp')
SMALL = os.path.join(ROOT, 'installer', 'wizard_small_image.bmp')

img = Image.open(SRC).convert('RGBA')
print('source size:', img.size, 'mode:', img.mode)

# Fit into a transparent square canvas (icons must be square).
size = max(img.size)
square = Image.new('RGBA', (size, size), (0, 0, 0, 0))
square.paste(img, ((size - img.width) // 2, (size - img.height) // 2), img)

square.save(ICO, format='ICO',
            sizes=[(256, 256), (128, 128), (64, 64), (48, 48), (32, 32), (16, 16)])
print('wrote', ICO)

# Installer wizard banner (164x314) centered on white.
banner = square.copy()
banner.thumbnail((164, 314), Image.LANCZOS)
canvas = Image.new('RGBA', (164, 314), (255, 255, 255, 255))
canvas.paste(banner, ((164 - banner.width) // 2, (314 - banner.height) // 2), banner)
os.makedirs(os.path.dirname(BANNER), exist_ok=True)
canvas.convert('RGB').save(BANNER, 'BMP')
print('wrote', BANNER)

# Installer wizard small image (55x58) centered on white.
small = square.copy()
small.thumbnail((55, 58), Image.LANCZOS)
c2 = Image.new('RGBA', (55, 58), (255, 255, 255, 255))
c2.paste(small, ((55 - small.width) // 2, (58 - small.height) // 2), small)
c2.convert('RGB').save(SMALL, 'BMP')
print('wrote', SMALL)
