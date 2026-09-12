"""Parse the ICO header directly to list frames + sizes, independent of Pillow quirks."""
import struct

p = r"C:\Users\aanan\Desktop\AANAND AB\PROJECTS\leadtoclose\windows\runner\resources\app_icon.ico"
with open(p, "rb") as f:
    data = f.read()

reserved, itype, count = struct.unpack_from("<HHH", data, 0)
print(f"ICO header: reserved={reserved}, type={itype}, count={count}, filesize={len(data)}")

for i in range(count):
    off = 6 + i * 16
    w, h, colors, rsv, planes, bpp, size, offset = struct.unpack_from("<BBBBHHII", data, off)
    w = w or 256
    h = h or 256
    # peek PNG signature to detect PNG-compressed frame
    png = data[offset:offset+8] == b"\x89PNG\r\n\x1a\n"
    print(f"  frame {i}: {w}x{h}, {bpp}bpp, {size} bytes, {'PNG' if png else 'BMP'}")
