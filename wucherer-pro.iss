; Wucherer-Pro Installer: installiert RustDesk still, setzt Server + zufälliges Dauerpasswort + Auto-Update.
; rustdesk.exe (offizieller Windows-Installer) muss neben dieser Datei liegen (macht die GitHub Action).
; Revalia-Regular.ttf (Google Font, für den "Wucherer.Pro"-Schriftzug) ebenfalls (macht die GitHub Action).

[Setup]
AppId={{6F1B7C3A-2D4E-4B8A-9E5C-1A7D3F0B9C42}
AppName=Wucherer-Pro
AppVersion=1.0
CreateAppDir=no
Uninstallable=no
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir=output
OutputBaseFilename=Wucherer-Pro
Compression=lzma2
SolidCompression=yes
DisableProgramGroupPage=yes
DisableWelcomePage=yes
DisableReadyPage=yes
WizardStyle=modern

[Languages]
Name: "de"; MessagesFile: "compiler:Languages\German.isl"

[Files]
Source: "rustdesk.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "Revalia-Regular.ttf"; DestDir: "{tmp}"; Flags: dontcopy

[Code]
const
  { In RustDesk: Einstellungen > Netzwerk > "Server-Konfiguration exportieren" }
  ServerConfig = 'HIER_EXPORTIERTEN_CONFIG_STRING_EINFUEGEN';
  { Dein eigenes, fest gewähltes Dauerpasswort. Du kennst es damit schon vorher,
    musst es beim Kunden nirgends ablesen. Mind. 6 Zeichen, 1 Buchstabe, 1 Zahl. }
  FixedPassword = 'HIER_DEIN_EIGENES_PASSWORT_EINTRAGEN123';
  FR_PRIVATE = 16;

var
  FontFilePath: String;
  InfoPage: TWizardPage;
  ChkInstall: TNewCheckBox;
  ChkUnattended: TNewCheckBox;

function AddFontResourceExW(lpszFilename: String; fl: Longint; pdv: Longint): Longint;
  external 'AddFontResourceExW@gdi32.dll stdcall';
function RemoveFontResourceExW(lpszFilename: String; fl: Longint; pdv: Longint): Longint;
  external 'RemoveFontResourceExW@gdi32.dll stdcall';

function RunHidden(const FileName, Params: String): Integer;
var
  RC: Integer;
begin
  if not Exec(FileName, Params, '', SW_HIDE, ewWaitUntilTerminated, RC) then
    RC := -1;
  Result := RC;
end;

procedure ToggleChkInstall(Sender: TObject);
begin
  ChkInstall.Checked := not ChkInstall.Checked;
end;

procedure ToggleChkUnattended(Sender: TObject);
begin
  ChkUnattended.Checked := not ChkUnattended.Checked;
end;

procedure InitializeWizard;
var
  TitleLbl, BodyLbl, LblInstall, LblUnattended: TNewStaticText;
  Margin, IndentLeft: Integer;
begin
  { Schriftart (Revalia) nur für diesen Installer laden, nicht systemweit installieren.
    FR_PRIVATE = nur für diesen Prozess sichtbar, wird beim Beenden automatisch entfernt. }
  ExtractTemporaryFile('Revalia-Regular.ttf');
  FontFilePath := ExpandConstant('{tmp}\Revalia-Regular.ttf');
  AddFontResourceExW(FontFilePath, FR_PRIVATE, 0);

  InfoPage := CreateCustomPage(wpWelcome, 'Wucherer.Pro Remote Support',
    'Bitte bestätigen Sie die folgenden Punkte, um die Einrichtung fortzusetzen.');

  { ScaleX/ScaleY: an die Windows-Skalierung (100%/125%/150% …) anpassen,
    sonst wirken die Kästchen bei höherer Skalierung abgeschnitten. }
  Margin := ScaleX(4);
  IndentLeft := Margin + ScaleX(28);

  TitleLbl := TNewStaticText.Create(InfoPage);
  TitleLbl.Parent := InfoPage.Surface;
  TitleLbl.AutoSize := True;
  TitleLbl.Left := Margin;
  TitleLbl.Top := 0;
  TitleLbl.Font.Name := 'Revalia';
  TitleLbl.Font.Size := 26;
  TitleLbl.Caption := 'Wucherer.Pro';

  BodyLbl := TNewStaticText.Create(InfoPage);
  BodyLbl.Parent := InfoPage.Surface;
  BodyLbl.Left := Margin;
  BodyLbl.Top := TitleLbl.Top + TitleLbl.Height + ScaleY(18);
  BodyLbl.Width := InfoPage.SurfaceWidth - Margin;
  BodyLbl.WordWrap := True;
  BodyLbl.Caption :=
    'Wucherer.Pro Remote Support richtet Ihren gesicherten Fernwartungszugang ' +
    'vollautomatisch ein. Nach Abschluss arbeitet die Software dauerhaft im ' +
    'Hintergrund – eine weitere Einrichtung durch Sie ist nicht erforderlich.';
  BodyLbl.AdjustHeight;

  ChkInstall := TNewCheckBox.Create(InfoPage);
  ChkInstall.Parent := InfoPage.Surface;
  ChkInstall.Caption := '';
  ChkInstall.Left := Margin;
  ChkInstall.Top := BodyLbl.Top + BodyLbl.Height + ScaleY(22);
  ChkInstall.Width := ScaleX(24);
  ChkInstall.Height := ScaleY(24);

  LblInstall := TNewStaticText.Create(InfoPage);
  LblInstall.Parent := InfoPage.Surface;
  LblInstall.Left := IndentLeft;
  LblInstall.Top := ChkInstall.Top;
  LblInstall.Width := InfoPage.SurfaceWidth - IndentLeft;
  LblInstall.WordWrap := True;
  LblInstall.OnClick := @ToggleChkInstall;
  LblInstall.Caption :=
    'Ich bestätige, dass Wucherer.Pro Remote Support installiert wird, dauerhaft im ' +
    'Hintergrund läuft und keine weitere Konfiguration durch mich erfordert.';
  LblInstall.AdjustHeight;

  ChkUnattended := TNewCheckBox.Create(InfoPage);
  ChkUnattended.Parent := InfoPage.Surface;
  ChkUnattended.Caption := '';
  ChkUnattended.Left := Margin;
  ChkUnattended.Top := LblInstall.Top + LblInstall.Height + ScaleY(18);
  ChkUnattended.Width := ScaleX(24);
  ChkUnattended.Height := ScaleY(24);

  LblUnattended := TNewStaticText.Create(InfoPage);
  LblUnattended.Parent := InfoPage.Surface;
  LblUnattended.Left := IndentLeft;
  LblUnattended.Top := ChkUnattended.Top;
  LblUnattended.Width := InfoPage.SurfaceWidth - IndentLeft;
  LblUnattended.WordWrap := True;
  LblUnattended.OnClick := @ToggleChkUnattended;
  LblUnattended.Caption :=
    'Ich nehme zur Kenntnis, dass ein Fernzugriff durch meinen Administrator technisch ' +
    'möglich ist und nur mit meiner ausdrücklichen Zustimmung erfolgt.';
  LblUnattended.AdjustHeight;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if (InfoPage <> nil) and (CurPageID = InfoPage.ID) then
  begin
    if not (ChkInstall.Checked and ChkUnattended.Checked) then
    begin
      MsgBox('Bitte bestätigen Sie beide Punkte, um mit der Einrichtung fortzufahren.',
        mbError, MB_OK);
      Result := False;
    end;
  end;
end;

procedure DeinitializeSetup;
begin
  if FontFilePath <> '' then
    RemoveFontResourceExW(FontFilePath, FR_PRIVATE, 0);
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  i: Integer;
  Exe, Pw, Id, IdFile, Msg: String;
  S: AnsiString;
begin
  if CurStep <> ssPostInstall then
    Exit;

  Exe := ExpandConstant('{commonpf64}\RustDesk\rustdesk.exe');
  Pw := FixedPassword;

  { 1. Still installieren (als Dienst) }
  RunHidden(ExpandConstant('{tmp}\rustdesk.exe'), '--silent-install');
  for i := 1 to 30 do
  begin
    if FileExists(Exe) then
      Break;
    Sleep(2000);
  end;
  Sleep(10000);

  { Desktop-Verknüpfung entfernen, die --silent-install automatisch anlegt }
  DeleteFile(ExpandConstant('{commondesktop}\RustDesk.lnk'));
  DeleteFile(ExpandConstant('{userdesktop}\RustDesk.lnk'));

  { 2. Server-Konfiguration, Dauerpasswort und Einstellungen setzen }
  RunHidden(Exe, '--config "' + ServerConfig + '"');
  RunHidden(Exe, '--password ' + Pw);
  RunHidden(Exe, '--option allow-auto-update Y');
  RunHidden(Exe, '--option verification-method use-permanent-password');
  RunHidden(Exe, '--option approve-mode password');
  RunHidden(Exe, '--option allow-remote-config-modification Y');
  RunHidden(Exe, '--option enable-keyboard Y');
  RunHidden(Exe, '--option enable-clipboard Y');
  RunHidden(Exe, '--option enable-file-transfer Y');
  { Ungetestet: ob sich das Verbindungsfenster so verstecken lässt, ist unklar.
    Diese Option gehört normalerweise zum kostenpflichtigen Custom Client Generator. }
  RunHidden(Exe, '--option allow-hide-cm N');

  { 3. Dienst neu starten, damit die Konfiguration greift }
  RunHidden(ExpandConstant('{sys}\net.exe'), 'stop RustDesk');
  Sleep(3000);
  RunHidden(ExpandConstant('{sys}\net.exe'), 'start RustDesk');
  Sleep(8000);

  { 4. ID auslesen (ohne "more", das sonst hängen bleiben kann) }
  IdFile := ExpandConstant('{tmp}\rid.txt');
  RunHidden(ExpandConstant('{cmd}'), '/c ""' + Exe + '" --get-id > "' + IdFile + '" 2>&1"');
  if LoadStringFromFile(IdFile, S) then
    Id := Trim(String(S))
  else
    Id := '(nicht lesbar)';

  { 5. Nur die ID anzeigen. Das Passwort kennst du bereits aus FixedPassword oben. }
  MsgBox('Wucherer.Pro Remote Support wurde erfolgreich eingerichtet.' + #13#10#13#10 +
         'Geräte-ID: ' + Id + #13#10#13#10 +
         'Bitte teilen Sie diese ID Ihrem Administrator mit.' + #13#10 +
         '(Strg+C kopiert den Text dieses Fensters.)', mbInformation, MB_OK);
end;
