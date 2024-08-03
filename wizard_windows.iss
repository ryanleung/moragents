[Setup]
AppName=MORagents
AppVersion=0.0.8
DefaultDirName={commonpf}\MORagents
OutputDir=.\MORagentsWindowsInstaller
OutputBaseFilename=MORagentsSetup
WizardStyle=modern

[Messages]
WelcomeLabel1=Welcome to the MORagents Setup Wizard. By proceeding you acknowledge you have read and agreed to the License found at: https://github.com/MorpheusAIs/moragents/blob/778b0aba68ae873d7bb355f2ed4419389369e042/LICENSE
WelcomeLabel2=This will install MORagents on your computer. Please click Next to continue.

[Files]
Source: "dist\MORagents\MORagents.exe"; DestDir: "{app}"
Source: "dist\MORagents\_internal\*"; DestDir: "{app}\_internal"; Flags: recursesubdirs
Source: "images\moragents.ico"; DestDir: "{app}"
Source: "LICENSE"; DestDir: "{app}"; Flags: isreadme
Source: "{tmp}\DockerDesktopInstaller.exe"; DestDir: "{tmp}"; Flags: external deleteafterinstall
Source: "{tmp}\OllamaSetup.exe"; DestDir: "{tmp}"; Flags: external deleteafterinstall
Source: "runtime_setup_windows.py"; DestDir: "{app}"

[Icons]
Name: "{commondesktop}\MORagents"; Filename: "{app}\MORagents.exe"; IconFilename: "{app}\moragents.ico"

[Run]
Filename: "{tmp}\DockerDesktopInstaller.exe"; Parameters: "install"; StatusMsg: "Installing Docker Desktop..."; Flags: waituntilterminated
Filename: "{tmp}\OllamaSetup.exe"; StatusMsg: "Installing Ollama..."; Flags: waituntilterminated
Filename: "{app}\LICENSE"; Description: "License Agreement"; Flags: postinstall shellexec skipifsilent
Filename: "{app}\MORagents.exe"; Description: "Launch MORagents"; Flags: postinstall nowait skipifsilent unchecked
Filename: "cmd.exe"; Parameters: "/c ollama pull llama3 && ollama pull nomic-embed-text"; StatusMsg: "Pulling Ollama models..."; Flags: runhidden waituntilterminated

[Code]
function InitializeSetup(): Boolean;
begin
  Result := MsgBox('Please read the license agreement found at https://github.com/MorpheusAIs/moragents/blob/778b0aba68ae873d7bb355f2ed4419389369e042/LICENSE carefully. Do you accept the terms of the License agreement?', mbConfirmation, MB_YESNO) = idYes;
  if not Result then
    MsgBox('Setup cannot continue without accepting the License agreement.', mbInformation, MB_OK);
end;

var
  DownloadPage: TDownloadWizardPage;

function OnDownloadProgress(const Url, FileName: String; const Progress, ProgressMax: Int64): Boolean;
begin
  if Progress = ProgressMax then
    Log(Format('Successfully downloaded file to {tmp}: %s', [FileName]));
  Result := True;
end;

procedure InitializeWizard;
begin
  DownloadPage := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), @OnDownloadProgress);
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  if CurPageID = wpReady then
  begin
    DownloadPage.Clear;
    DownloadPage.Add('https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe', 'DockerDesktopInstaller.exe', '');
    DownloadPage.Add('https://ollama.com/download/OllamaSetup.exe', 'OllamaSetup.exe', '');
    DownloadPage.Show;
    try
      try
        DownloadPage.Download; // This downloads the files to {tmp}
        Result := True;
      except
        if DownloadPage.AbortedByUser then
          Log('Aborted by user.')
        else
          SuppressibleMsgBox(AddPeriod(GetExceptionMessage), mbCriticalError, MB_OK, IDOK);
        Result := False;
      end;
    finally
      DownloadPage.Hide;
    end;
  end
  else
    Result := True;
end;