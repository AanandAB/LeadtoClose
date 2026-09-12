"""Diagnose the app icon: is the logo visible, and is it embedded in the exe?"""
import ctypes
from ctypes import wintypes
from PIL import Image

ROOT = r"C:\Users\aanan\Desktop\AANAND AB\PROJECTS\leadtoclose"
EXE = ROOT + r"\build\windows\x64\runner\Release\freelancehub.exe"


def visibility(path, label):
    im = Image.open(path).convert("RGBA")
    px = list(im.getdata())
    n = len(px)
    opaque = sum(1 for p in px if p[3] > 128)
    nonblank = sum(1 for p in px if p[3] > 0)
    if opaque:
        mr = sum(p[0] for p in px if p[3] > 128) / opaque
        mg = sum(p[1] for p in px if p[3] > 128) / opaque
        mb = sum(p[2] for p in px if p[3] > 128) / opaque
    else:
        mr = mg = mb = 0.0
    print(f"{label}: {im.size}, opaque={opaque}/{n} ({100*opaque//n}%), "
          f"nonblank={nonblank}/{n}, meanRGB=({mr:.0f},{mg:.0f},{mb:.0f})")
    return opaque


print("=== 1. source logo PNG ===")
visibility(ROOT + r"\assets\freelancehub_logo.png", "logo")

print("\n=== 2. app_icon.ico per-frame ===")
im = Image.open(ROOT + r"\windows\runner\resources\app_icon.ico")
nframes = getattr(im, "n_frames", 1)
print("frame count:", nframes)
for idx in range(nframes):
    im.seek(idx)
    f = im.convert("RGBA")
    s = f.size
    px = list(f.getdata())
    n = len(px)
    opaque = sum(1 for p in px if p[3] > 128)
    print(f"  {s[0]}x{s[1]}: opaque={opaque}/{n} ({100*opaque//n}%)")

print("\n=== 3. icon embedded in exe ===")
shell32 = ctypes.windll.shell32
user32 = ctypes.windll.user32
gdi32 = ctypes.windll.gdi32

ExtractIconExW = shell32.ExtractIconExW
ExtractIconExW.argtypes = [wintypes.LPCWSTR, ctypes.c_int,
                           ctypes.POINTER(wintypes.HICON),
                           ctypes.POINTER(wintypes.HICON), ctypes.c_uint]
ExtractIconExW.restype = ctypes.c_uint

large = wintypes.HICON()
small = wintypes.HICON()
n = ExtractIconExW(EXE, 0, ctypes.byref(large), ctypes.byref(small), 1)
print(f"ExtractIconExW returned {n} icon(s); large={large.value}, small={small.value}")

if large.value:
    class ICONINFO(ctypes.Structure):
        _fields_ = [("fIcon", wintypes.BOOL),
                    ("xHotspot", wintypes.DWORD),
                    ("yHotspot", wintypes.DWORD),
                    ("hbmMask", wintypes.HBITMAP),
                    ("hbmColor", wintypes.HBITMAP)]
    ii = ICONINFO()
    if user32.GetIconInfo(large, ctypes.byref(ii)):
        class BITMAP(ctypes.Structure):
            _fields_ = [("bmType", ctypes.c_long), ("bmWidth", ctypes.c_long),
                        ("bmHeight", ctypes.c_long), ("bmWidthBytes", ctypes.c_long),
                        ("bmPlanes", wintypes.WORD), ("bmBitsPixel", wintypes.WORD),
                        ("bmBits", ctypes.c_void_p)]
        bm = BITMAP()
        if ii.hbmColor and gdi32.GetObjectW(ii.hbmColor, ctypes.sizeof(bm), ctypes.byref(bm)):
            print(f"large icon bitmap: {bm.bmWidth}x{bm.bmHeight}, {bm.bmBitsPixel}bpp")
        else:
            print("no color bitmap (monochrome icon?) -> likely BLANK/invalid")
        if ii.hbmColor:
            gdi32.DeleteObject(ii.hbmColor)
        if ii.hbmMask:
            gdi32.DeleteObject(ii.hbmMask)
    else:
        print("GetIconInfo failed")
    user32.DestroyIcon(large)
    if small.value:
        user32.DestroyIcon(small)
else:
    print("NO ICON EXTRACTED FROM EXE -- the icon resource is missing/not embedded!")
