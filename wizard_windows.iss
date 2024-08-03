[Setup]
AppName=MORagents
AppVersion=0.0.8
DefaultDirName={commonpf}\MORagents
OutputDir=.\MORagentsWindowsInstaller
OutputBaseFilename=MORagentsSetup

[Messages]
WelcomeLabel1=Welcome to the MORagents Setup Wizard. By proceeding you acknowledge you have read and agreed to the License found at: https://github.com/MorpheusAIs/moragents/blob/778b0aba68ae873d7bb355f2ed4419389369e042/LICENSE
WelcomeLabel2=This will install MORagents on your computer. Please click Next to continue.

[Files]
Source: "dist\MORagents\MORagents.exe"; DestDir: "{app}"
Source: "dist\MORagents\_internal\*"; DestDir: "{app}\_internal"; Flags: recursesubdirs
Source: "images\moragents.ico"; DestDir: "{app}"
Source: "LICENSE"; DestDir: "{app}"; Flags: isreadme
Source: "https://desktop.docker.com/win/stable/Docker Desktop Installer.exe"; DestDir: "{tmp}"; DestName: "DockerDesktopInstaller.exe"; Flags: external deleteafterinstall
Source: "runtime_setup_windows.py"; DestDir: "{app}"

[Icons]
Name: "{commondesktop}\MORagents"; Filename: "{app}\MORagents.exe"; IconFilename: "{app}\moragents.ico"

[Run]
Filename: "{tmp}\DockerDesktopInstaller.exe"; Parameters: "install"; StatusMsg: "Installing Docker Desktop..."; Flags: waituntilterminated
Filename: "{app}\LICENSE"; Description: "License Agreement"; Flags: postinstall shellexec skipifsilent
Filename: "{app}\MORagents.exe"; Description: "Launch MORagents"; Flags: postinstall nowait skipifsilent unchecked


[Code]
function InitializeSetup(): Boolean;
begin
    Result := MsgBox('Please read the license agreement found at https://github.com/MorpheusAIs/moragents/blob/778b0aba68ae873d7bb355f2ed4419389369e042/LICENSE carefully. Do you accept the terms of the License agreement?', mbConfirmation, MB_YESNO) = idYes;
    if not Result then
        MsgBox('Setup cannot continue without accepting the License agreement.', mbInformation, MB_OK);
end;