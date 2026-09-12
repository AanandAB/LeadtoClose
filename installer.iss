; FreelanceHub — Windows installer (per-user, no admin required)
; Build with: "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer.iss

[Setup]
AppId={{e553e3f8-5c5e-4d84-87cb-3c693de1b5e7}
AppName=FreelanceHub
AppVersion=2.1.0
AppPublisher=Aanand AB
AppPublisherURL=https://github.com/AanandAB
DefaultDirName={localappdata}\FreelanceHub
DefaultGroupName=FreelanceHub
DisableProgramGroupPage=yes
OutputDir=installer
OutputBaseFilename=FreelanceHub_Setup_v2.1.0
Compression=lzma2
SolidCompression=yes
SetupIconFile=windows\runner\resources\app_icon.ico
WizardImageFile=installer\wizard_image.bmp
WizardSmallImageFile=installer\wizard_small_image.bmp
UninstallDisplayIcon={app}\freelancehub.exe
PrivilegesRequired=lowest
WizardStyle=modern

[Files]
Source: "build\windows\x64\runner\Release\freelancehub.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\pdfium.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\printing_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\share_plus_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\url_launcher_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\FreelanceHub"; Filename: "{app}\freelancehub.exe"
Name: "{autodesktop}\FreelanceHub"; Filename: "{app}\freelancehub.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop shortcut"; GroupDescription: "Additional shortcuts:"

[Run]
Filename: "{app}\freelancehub.exe"; Description: "Launch FreelanceHub"; Flags: nowait postinstall skipifsilent
