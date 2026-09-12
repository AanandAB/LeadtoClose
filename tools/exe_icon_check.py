"""Render the exe's embedded icon and report its mean color, to tell logo vs Flutter default."""
import ctypes
from ctypes import wintypes

EXE = r"C:\Users\aanan\Desktop\AANAND AB\PROJECTS\leadtoclose\build\windows\x64\runner\Release\freelancehub.exe"

user32 = ctypes.windll.user32
gdi32 = ctypes.windll.gdi32
shell32 = ctypes.windll.shell32

large = wintypes.HICON()
small = wintypes.HICON()
n = shell32.ExtractIconExW(EXE, 0, ctypes.byref(large), ctypes.byref(small), 1)
print("icons extracted:", n)


class ICONINFO(ctypes.Structure):
    _fields_ = [("fIcon", ctypes.c_int), ("xHotspot", ctypes.c_uint32),
                ("yHotspot", ctypes.c_uint32), ("hbmMask", ctypes.c_void_p),
                ("hbmColor", ctypes.c_void_p)]


ii = ICONINFO()
if not user32.GetIconInfo(large, ctypes.byref(ii)):
    print("GetIconInfo failed")
    raise SystemExit(1)


class BITMAP(ctypes.Structure):
    _fields_ = [("bmType", ctypes.c_long), ("bmWidth", ctypes.c_long),
                ("bmHeight", ctypes.c_long), ("bmWidthBytes", ctypes.c_long),
                ("bmPlanes", ctypes.c_ushort), ("bmBitsPixel", ctypes.c_ushort),
                ("bmBits", ctypes.c_void_p)]


bm = BITMAP()
gdi32.GetObjectW(ii.hbmColor, ctypes.sizeof(BITMAP), ctypes.byref(bm))
w, h = bm.bmWidth, bm.bmHeight
print(f"color bitmap: {w}x{h}, {bm.bmBitsPixel}bpp")


class BITMAPINFOHEADER(ctypes.Structure):
    _fields_ = [("biSize", ctypes.c_uint32), ("biWidth", ctypes.c_int32),
                ("biHeight", ctypes.c_int32), ("biPlanes", ctypes.c_ushort),
                ("biBitCount", ctypes.c_ushort), ("biCompression", ctypes.c_uint32),
                ("biSizeImage", ctypes.c_uint32), ("biXPelsPerMeter", ctypes.c_int32),
                ("biYPelsPerMeter", ctypes.c_int32), ("biClrUsed", ctypes.c_uint32),
                ("biClrImportant", ctypes.c_uint32)]


class BITMAPINFO(ctypes.Structure):
    _fields_ = [("bmiHeader", BITMAPINFOHEADER), ("bmiColors", ctypes.c_uint32 * 3)]


bmi = BITMAPINFO()
bmi.bmiHeader.biSize = ctypes.sizeof(BITMAPINFOHEADER)
bmi.bmiHeader.biWidth = w
bmi.bmiHeader.biHeight = -h  # top-down
bmi.bmiHeader.biPlanes = 1
bmi.bmiHeader.biBitCount = 32
bmi.bmiHeader.biCompression = 0

hdc = user32.GetDC(0)
buf = (ctypes.c_ubyte * (w * h * 4))()
got = gdi32.GetDIBits(hdc, ii.hbmColor, 0, h, buf, ctypes.byref(bmi), 0)
user32.ReleaseDC(0, hdc)
print("scanlines read:", got)

n = w * h
r = sum(buf[i * 4 + 2] for i in range(n)) // n
g = sum(buf[i * 4 + 1] for i in range(n)) // n
b = sum(buf[i * 4 + 0] for i in range(n)) // n
print(f"EXE icon mean RGB: ({r},{g},{b})")

# Sample a few pixels near center
cx, cy = w // 2, h // 2
for (x, y) in [(cx, cy), (w // 4, h // 4), (3 * w // 4, 3 * h // 4), (w // 2, 10)]:
    i = (y * w + x) * 4
    print(f"  pixel({x},{y}) = RGB({buf[i+2]},{buf[i+1]},{buf[i]}) A={buf[i+3]}")

if r < 40 and g < 40 and b < 60:
    print("\nVERDICT: dark navy -> this IS the FreelanceHub logo (correctly embedded)")
else:
    print("\nVERDICT: bright/blue -> this looks like the DEFAULT Flutter icon (build did NOT pick up the new icon)")

user32.DestroyIcon(large)
if small.value:
    user32.DestroyIcon(small)
gdi32.DeleteObject(ii.hbmColor)
gdi32.DeleteObject(ii.hbmMask)
