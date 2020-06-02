unit FarCry2MFL_Proc;

//--------------------------------------------------------------------------------------------------
interface
//--------------------------------------------------------------------------------------------------

uses
  StdCtrls;

type
  TOptionSubItem = record
    Key: string;
    Name: string;
    Value: Variant;
    Default: Variant;
  end;

  TOptionSubItems = array of TOptionSubItem;

  POptionItem = ^TOptionItem;

  TOptionItem = record
    Key: string;
    Name: string;
    Checked: Boolean;
    Default: Boolean;
    ParentIndex: Integer;
    Description: string;
    OptionSubItems: TOptionSubItems;
  end;

  TDllLoadingState = (dlsNone, dlsLoading, dlsOK, dlsError);

  // These parameters no need to pass into DLL
  TCommandLineOptions = record
    bSkipIntroMovies: Boolean;
    bMaxFps: Boolean;
    iMaxFps: Integer;
    bAllWeaponsUnlock: Boolean;
    bUnlimitedReliability: Boolean;
    bUnlimitedAmmo: Boolean;
    bGodMode: Boolean;
    bZombieAI: Boolean;
    bExec: Boolean;
    sExec: string;
  end;

  TGameFilesInfo = record
    FarCry2ExeSize: Integer;
    FarCry2ExeCRC32: Cardinal;
    DuniaDllSize: Integer;
    VersionStringOffset: Integer;
  end;

  TGameFilesInfos = array[1..3] of TGameFilesInfo;

const
  GameFilesInfo: TGameFilesInfos =((
    // Steam
    FarCry2ExeSize: 28296;
    FarCry2ExeCRC32: $5F78917A;
    DuniaDllSize: 20183176;
    VersionStringOffset: $00E37F54
  ),(
    // Retail
    FarCry2ExeSize: 28296;
    FarCry2ExeCRC32: $0FC58B66;
    DuniaDllSize: 19412104;
    VersionStringOffset: $00DB1FC4
  ),(
    // Uplay
    FarCry2ExeSize: 29864;
    FarCry2ExeCRC32: $8CF778F0;
    DuniaDllSize: 20184168;
    VersionStringOffset: $00E37F54
  ));

var
  FarCry2ExeName: string;
  DuniaDllName: string;
  DllName: string;
  DllLoadingState: TDllLoadingState;
  LogMemo: TMemo;
  DebugEnabled: Boolean;
  WaitProcess: Boolean;
  OptionItems: array of TOptionItem;
  CommandLineOptions: TCommandLineOptions;

function AlreadyRunning(): Boolean;

function CheckLaunchClose(): Boolean;

function GameIsRunning(): Boolean;

function CurrentFileInfo(NameApp: string): string;

function GetFileSize(FileName: string): Cardinal;

function GetOptionByKey(Key: string): Variant;

procedure SetOptionByKey(Key: string; Value: Variant);

function GetProcessHandle(Name: string): THandle;

function InitializeVars(): Boolean;

function IsSilentLaunch(): Boolean;

procedure CreateLnk(FileName, Path, WorkingDirectory, Description, Arguments: string);

procedure LoadFormOptionsFromXML();

procedure Log(Str: string);

procedure SaveOptionsToINI();

procedure SetFileNameIfExist(var Variable: string; FileName: string);

procedure ShowOptionsDialog();

procedure ShowProgressDialog(TimeOut: Integer);

procedure SetDuniaDllName();

procedure TrySetFarCry2ExeName(Path: string);

function CalcFileCRC32(FileName: string): Cardinal;

function IndexByGameFilesInfo(FarCry2ExeSize: Integer; FarCry2ExeCRC32: Cardinal; DuniaDllSize: Integer): Integer;

function GetGameVersion(): Integer;

//--------------------------------------------------------------------------------------------------
implementation
//--------------------------------------------------------------------------------------------------

uses
  ActiveX,
  FarCry2MF_Options,
  FarCry2MFL_FormOptions,
  FarCry2MFL_FormProgress,
  FarCry2MFL_InstallSearch,
  ComObj,
  Classes,
  Controls,
  Forms,
  IniFiles,
  ShlObj,
  SysUtils,
  TlHelp32,
  Types,
  UnitCRC32,
  XMLDoc,
  XMLIntf,
  Windows,
  Variants;

function AlreadyRunning(): Boolean;
begin
  CreateMutex(nil, True, 'FarCry2MFLauncher Once Only');
  Result := (GetLastError = ERROR_ALREADY_EXISTS);
end;

function GameIsRunning(): Boolean;
var
  Mutex: THandle;
begin
  Mutex := OpenMutex(SYNCHRONIZE, False, 'FarCry2Instance');
  Result := Mutex <> 0;
  if Result then
    CloseHandle(Mutex);
end;

procedure Zero(Destination: Pointer);
begin
  FillChar(Destination^, SizeOf(Destination^), 0);
end;

function QuoteIfSpaces(const S: string): string;
var
  L: Integer;
begin
  Result := Trim(S);
  if Pos(' ', Result) > 0 then
  begin
    L := Length(Result);
    if L > 0 then
    begin
      if (Result[1] = '"') and (Result[L] = '"') then
        Exit
      else
        Result := '"' + Result + '"';
    end;
  end;
end;

function CurrentFileInfo(NameApp: string): string;
var
  Dump: DWORD;
  Size: Integer;
  Buffer: PChar;
  VersionPointer, TransBuffer: PChar;
  Temp: Integer;
  CalcLangCharSet: string;
begin
  Size := GetFileVersionInfoSize(PChar(NameApp), Dump);
  Buffer := StrAlloc(Size + 1);
  try
    GetFileVersionInfo(PChar(NameApp), 0, Size, Buffer);

    VerQueryValue(Buffer, '\VarFileInfo\Translation', Pointer(TransBuffer), Dump);
    if Dump >= 4 then
    begin
      Temp := 0;
      StrLCopy(@Temp, TransBuffer, 2);
      CalcLangCharSet := IntToHex(Temp, 4);
      StrLCopy(@Temp, TransBuffer + 2, 2);
      CalcLangCharSet := CalcLangCharSet + IntToHex(Temp, 4);
    end;

    VerQueryValue(Buffer, PChar('\StringFileInfo\' + CalcLangCharSet + '\' + 'FileVersion'), Pointer(VersionPointer), Dump);
    if (Dump > 1) then
    begin
      SetLength(Result, Dump);
      StrLCopy(PChar(Result), VersionPointer, Dump);
    end
    else
      Result := '0.0.0.0';
  finally
    StrDispose(Buffer);
  end;
end;

function IsSilentLaunch(): Boolean;
begin
  Result := FindCmdLineSwitch('play');
end;

procedure INIReadToOptionByKey(OptionsINI: TMemIniFile; Section, Key: string; DefaultValue: Variant);
var
  CurrentValue: Variant;
  Value: Variant;
begin
  CurrentValue := GetOptionByKey(Key);
  case VarType(CurrentValue) of
    varBoolean:
      Value := OptionsINI.ReadBool(Section, Key, DefaultValue);
    varInteger, varSmallint, varByte, varWord, varLongWord:
      Value := OptionsINI.ReadInteger(Section, Key, DefaultValue);
    varString:
      Value := OptionsINI.ReadString(Section, Key, DefaultValue);
  end;
  if not VarIsEmpty(Value) then
    SetOptionByKey(Key, Value);
end;

procedure INIWriteFromOptionByKey(OptionsINI: TMemIniFile; Section, Key: string; Default: Variant);
var
  Value: Variant;
begin
  Value := GetOptionByKey(Key);
  if Value <> Default then
  begin
    case VarType(Value) of
      varBoolean:
        OptionsINI.WriteBool(Section, Key, Value);
      varInteger, varSmallint, varByte, varWord, varLongWord:
        OptionsINI.WriteInteger(Section, Key, Value);
      varString:
        OptionsINI.WriteString(Section, Key, Value);
    end;
  end;
end;

procedure LoadOptionsFromINI();
var
  OptionsINI: TMemIniFile;
  INIFileName: string;
  i, j: Integer;
  Section: string;
  Key: string;
begin
  INIFileName := ChangeFileExt(Application.ExeName, '.ini');
  OptionsINI := TMemIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  for i := 0 to High(OptionItems) do
  begin
    Key := OptionItems[i].Key;
    if (Key = '') and (Section <> OptionItems[i].Name) then
      Section := OptionItems[i].Name;
    if Key <> '' then
      INIReadToOptionByKey(OptionsINI, Section, Key, OptionItems[i].Default);
    for j := 0 to High(OptionItems[i].OptionSubItems) do
      INIReadToOptionByKey(OptionsINI, Section, OptionItems[i].OptionSubItems[j].Key, OptionItems[i].OptionSubItems[j].Default);
  end;
  OptionsINI.Free;
end;

procedure SaveOptionsToINI();
var
  OptionsINI: TMemIniFile;
  INIFileName: string;
  i, j: Integer;
  Section: string;
  Key: string;
  INIStrings: TStrings;
begin
  INIFileName := ChangeFileExt(Application.ExeName, '.ini');
  DeleteFile(PChar(INIFileName));
  OptionsINI := TMemIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  for i := 0 to High(OptionItems) do
  begin
    Key := OptionItems[i].Key;
    if (Key = '') and (Section <> OptionItems[i].Name) then
      Section := OptionItems[i].Name;
    if Key <> '' then
      INIWriteFromOptionByKey(OptionsINI, Section, Key, OptionItems[i].Default);
    for j := 0 to High(OptionItems[i].OptionSubItems) do
      INIWriteFromOptionByKey(OptionsINI, Section, OptionItems[i].OptionSubItems[j].Key, OptionItems[i].OptionSubItems[j].Default);
  end;
  INIStrings := TStringList.Create;
  try
    OptionsINI.GetStrings(INIStrings);
    if INIStrings.Count > 0 then
      OptionsINI.UpdateFile;
  finally
    INIStrings.Free;
  end;
  OptionsINI.Free;
end;

function InitializeVars(): Boolean;
var
  MyPath: string;
  i: Integer;
begin
  CoInitialize(nil);
  MyPath := ExtractFilePath(Application.ExeName);
  TrySetFarCry2ExeName(MyPath);
  SetFileNameIfExist(DllName, MyPath + 'FarCry2MF.dll');
  for i := 1 to ParamCount do
  begin
    if ParamStr(i) = '-exe' then
      SetFileNameIfExist(FarCry2ExeName, ParamStr(i + 1));
    if ParamStr(i) = '-dll' then
      SetFileNameIfExist(DllName, ParamStr(i + 1));
  end;
  TrySetFarCry2ExeName(GetInstallLocation() + '\');

  SetDuniaDllName();

  DebugEnabled := FindCmdLineSwitch('debug');
  WaitProcess := FindCmdLineSwitch('wait');
  Result := (FarCry2ExeName <> '') and (DuniaDllName <> '') and (DllName <> '');
  LoadFormOptionsFromXML();
  LoadOptionsFromINI();
end;

procedure Log(Str: string);
begin
  if LogMemo <> nil then
    if Str = '' then
      LogMemo.Lines.Clear()
    else
    begin
      while LogMemo.Lines.Count >= 100 do
        LogMemo.Lines.Delete(0);
      LogMemo.Lines.Add(Str);
      LogMemo.Text := Trim(LogMemo.Text);
    end;
end;

function LaunchGame(): TProcessInformation;
var
  FileName: string;
  CommandLine: string;
  Path: string;
  StartupInfo: TStartupInfo;
  ProcessInformation: TProcessInformation;
  Context: TContext;
  Inject: packed record
    PushCommand: Byte;
    PushArgument: Cardinal;
    CallCommand: Word;
    CallAddr: Cardinal;
    JumpCommand: Byte;
    JumpOffset: Byte;
    AddrLoadLibrary: Pointer;
    LibraryName: array[0..$FF] of Char;   // + 0x0D
  end;
  SavedBytes: array[0..$1FF] of Byte;
  EntryPointAddress: Cardinal;
  BytesRead: Cardinal;
  BytesWritten: Cardinal;
  i: Integer;
  UplayPatchAddress: Pointer;
  UplayPatch: array[0..4] of Cardinal;
begin
  try
    DllLoadingState := dlsNone;
    FileName := FarCry2ExeName;
    CommandLine := FarCry2ExeName;
    if CommandLineOptions.bSkipIntroMovies then
      CommandLine := CommandLine + ' -GameProfile_SkipIntroMovies 1';
    if CommandLineOptions.bMaxFps then
      CommandLine := CommandLine + ' -RenderProfile_MaxFps ' + IntToStr(CommandLineOptions.iMaxFps);

    if CommandLineOptions.bAllWeaponsUnlock then
      CommandLine := CommandLine + ' -GameProfile_AllWeaponsUnlock 1';
    if CommandLineOptions.bUnlimitedReliability then
      CommandLine := CommandLine + ' -GameProfile_UnlimitedReliability 1';
    if CommandLineOptions.bUnlimitedAmmo then
      CommandLine := CommandLine + ' -GameProfile_UnlimitedAmmo 1';
    if CommandLineOptions.bGodMode then
      CommandLine := CommandLine + ' -GameProfile_GodMode 1';
    if CommandLineOptions.bZombieAI then
      CommandLine := CommandLine + ' -zombieai';

    if CommandLineOptions.bExec and (CommandLineOptions.sExec <> '') then
      CommandLine := CommandLine + ' -exec ' + QuoteIfSpaces(CommandLineOptions.sExec);

    Path := ExtractFilePath(FarCry2ExeName);
    ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
    StartupInfo.cb := SizeOf(StartupInfo);
    ZeroMemory(@ProcessInformation, SizeOf(ProcessInformation));
    if not CreateProcess(PAnsiChar(FileName), PAnsiChar(CommandLine), nil, nil, False, CREATE_SUSPENDED, nil, PAnsiChar(Path), StartupInfo, ProcessInformation) then
      raise Exception.Create('CreateProcess: ' + IntToStr(GetLastError()));
    EntryPointAddress := $004014EC;
    ZeroMemory(@Inject, SizeOf(Inject));
    Inject.PushCommand := $68;
    Inject.PushArgument := EntryPointAddress + $11;
    Inject.CallCommand := $15FF;
    Inject.CallAddr := EntryPointAddress + $0D;
    Inject.JumpCommand := $EB;
    Inject.JumpOffset := $FE;
    Inject.AddrLoadLibrary := GetProcAddress(GetModuleHandle('kernel32.dll'), 'LoadLibraryA');
    if Length(DllName) >= Length(Inject.LibraryName) then
      raise Exception.Create('Too long DllName: ' + DllName);
    StrPCopy(Inject.LibraryName, DllName);
    if not ReadProcessMemory(ProcessInformation.hProcess, Pointer(EntryPointAddress), @SavedBytes, SizeOf(SavedBytes), BytesRead) then
      raise Exception.Create('ReadProcessMemory: ' + IntToStr(GetLastError()));
    Log('BytesRead ' + IntToStr(BytesRead));
    if not WriteProcessMemory(ProcessInformation.hProcess, Pointer(EntryPointAddress), @Inject, SizeOf(Inject), BytesWritten) then
      raise Exception.Create('WriteProcessMemory1: ' + IntToStr(GetLastError()));
    Log('BytesWritten ' + IntToStr(BytesWritten));
    if not WriteProcessMemory(ProcessInformation.hProcess, FC2MFOptions, @Options, SizeOf(Options), BytesWritten) then
      raise Exception.Create('WriteProcessMemory2: ' + IntToStr(GetLastError()));
    Log('BytesWritten ' + IntToStr(BytesWritten));
    if CalcFileCRC32(FarCry2ExeName) = GameFilesInfo[GAME_VERSION_UPLAY].FarCry2ExeCRC32 then
    begin
      UplayPatchAddress := Pointer($0040903C); //IMAGE_IMPORT_DESCRIPTOR[3]
      ZeroMemory(@UplayPatch, SizeOf(UplayPatch));
      if not WriteProcessMemory(ProcessInformation.hProcess, UplayPatchAddress, @UplayPatch, SizeOf(UplayPatch), BytesWritten) then
        raise Exception.Create('WriteProcessMemory3: ' + IntToStr(GetLastError()));
      Log('BytesWritten ' + IntToStr(BytesWritten));
    end;

    DllLoadingState := dlsLoading;

    if ResumeThread(ProcessInformation.hThread) = $FFFFFFFF then
      raise Exception.Create('ResumeThread: ' + IntToStr(GetLastError()));

    ShowProgressDialog(10);

    if DllLoadingState = dlsError then
      raise Exception.Create('There was an error while loading dll');
    if DllLoadingState <> dlsOK then
      raise Exception.Create('Dll not loaded');
    if SuspendThread(ProcessInformation.hThread) = $FFFFFFFF then
      raise Exception.Create('SuspendThread: ' + IntToStr(GetLastError()));
    if not WriteProcessMemory(ProcessInformation.hProcess, Pointer(EntryPointAddress), @SavedBytes, SizeOf(SavedBytes), BytesWritten) then
      raise Exception.Create('WriteProcessMemory3: ' + IntToStr(GetLastError()));
    Log('BytesWritten ' + IntToStr(BytesWritten));
    ZeroMemory(@Context, SizeOf(Context));
    Context.ContextFlags := CONTEXT_FULL;
    if not GetThreadContext(ProcessInformation.hThread, Context) then
      raise Exception.Create('GetThreadContext: ' + IntToStr(GetLastError()));
    Context.Eip := EntryPointAddress;
    if not SetThreadContext(ProcessInformation.hThread, Context) then
      raise Exception.Create('SetThreadContext: ' + IntToStr(GetLastError()));
    if ResumeThread(ProcessInformation.hThread) = $FFFFFFFF then
      raise Exception.Create('ResumeThread: ' + IntToStr(GetLastError()));
    Result := ProcessInformation;
  except
    if (ProcessInformation.hProcess <> 0) then
      TerminateProcess(ProcessInformation.hProcess, 1);
    raise;

  end;

end;

function Check(): Boolean;
begin
  if not FileExists(FarCry2ExeName) then
    raise Exception.Create('Game exe file ' + FarCry2ExeName + 'does not exist (FarCry2.exe not found)');
  if not FileExists(DuniaDllName) then
    raise Exception.Create('Game engine file ' + DuniaDllName + 'does not exist (Dunia.dll not found)');
  if not FileExists(DllName) then
    raise Exception.Create('Dll file ' + DllName + 'does not exist (FarCry2MF.dll not found)');
  Options.Version := GetGameVersion();
  Result := True;
end;

function CheckLaunchClose(): Boolean;
var
  PI: TProcessInformation;
begin
  Result := False;
  Log('');
  try
    Check();
    LoadOptionsFromINI();
    PI := LaunchGame();
    if not DebugEnabled then
    begin
      if WaitProcess then
      begin
        while (WaitForSingleObject(PI.hProcess, 500) = WAIT_TIMEOUT) do
          ;
      end;
      Result := True;
      Application.Terminate();
    end;
  except
    on E: Exception do
      Log('Error: ' + E.message);
  end;
end;

procedure CreateLnk(FileName, Path, WorkingDirectory, Description, Arguments: string);
var
  ComObject: IUnknown;
  ShellLink: IShellLink;
  PersistFile: IPersistFile;
begin
  CoInitialize(nil);
  ComObject := CreateComObject(CLSID_ShellLink);
  ShellLink := ComObject as IShellLink;
  PersistFile := ComObject as IPersistFile;
  ShellLink.SetPath(PChar(Path));
  ShellLink.SetWorkingDirectory(PChar(WorkingDirectory));
  ShellLink.SetDescription(PChar(Description));
  ShellLink.SetArguments(PChar(Arguments));
  PersistFile.Save(PWideChar(WideString(ChangeFileExt(FileName, '.lnk'))), False);
  CoUninitialize();
end;

procedure SetFileNameIfExist(var Variable: string; FileName: string);
begin
  if FileExists(FileName) then
    Variable := FileName;
end;

function GetFileSize(FileName: string): Cardinal;
var
  sr: TSearchRec;
begin
  Result := 0;
  if SysUtils.FindFirst(FileName, faAnyFile, sr) = 0 then
  begin
    Result := sr.Size;
    SysUtils.FindClose(sr);
  end;
end;

function GetProcessHandle(Name: string): THandle;
var
  Snapshot: THandle;
  PE32: TProcessEntry32;
begin
  Result := 0;
  Snapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if Snapshot = INVALID_HANDLE_VALUE then
    Exit;
  PE32.dwSize := SizeOf(TProcessEntry32);
  if (Process32First(Snapshot, PE32)) then
    repeat
      if CompareText(ExtractFileName(PE32.szExeFile), Name) = 0 then
        Result := PE32.th32ProcessID;
    until not Process32Next(Snapshot, PE32);
  CloseHandle(Snapshot);
end;

procedure ShowOptionsDialog();
var
  FormOptions: TFormOptions;
begin
  FormOptions := TFormOptions.Create(Application);
  if FormOptions.ShowModal() = mrOk then
  begin
    try
      SaveOptionsToINI();
    except
    end;
  end;
  FormOptions.Free;
end;

procedure ShowProgressDialog(TimeOut: Integer);
var
  FormProgress: TFormProgress;
begin
  FormProgress := TFormProgress.Create(Application);
  FormProgress.StartTimer(TimeOut);
  FormProgress.ShowModal();
  FormProgress.Free;
end;

procedure SetDuniaDllName();
var
  GamePath: string;
begin
  if FarCry2ExeName <> '' then
  begin
    GamePath := ExtractFilePath(FarCry2ExeName);
    SetFileNameIfExist(DuniaDllName, GamePath + '\Dunia.dll');
  end;
end;

procedure TrySetFarCry2ExeName(Path: string);
var
  SearchRec: TSearchRec;
  SearchMask: string;
  FileName: string;
  BestMatch: Integer;
  CurrentMatch: Integer;
begin
  if FarCry2ExeName = '' then
  begin
    if DirectoryExists(Path) then
    begin
      SearchMask := Path + '*.exe';
      if SysUtils.FindFirst(SearchMask, faAnyFile, SearchRec) = 0 then
      begin
        BestMatch := 0;
        repeat
          CurrentMatch := 0;
          FileName := Path + SearchRec.Name;
          if SameText(SearchRec.Name, 'FarCry2.exe') then
            CurrentMatch := CurrentMatch + 1;
          if IndexByGameFilesInfo(SearchRec.Size, 0, 0) > 0 then
            CurrentMatch := CurrentMatch + 2;
          if IndexByGameFilesInfo(0, CalcFileCRC32(FileName), 0) > 0 then
            CurrentMatch := CurrentMatch + 4;
          if CurrentMatch > BestMatch then
          begin
            BestMatch := CurrentMatch;
            FarCry2ExeName := FileName;
          end;
        until SysUtils.FindNext(SearchRec) <> 0;
        SysUtils.FindClose(SearchRec);
      end;
    end;
  end;
end;

function CalcFileCRC32(FileName: string): Cardinal;
var
  FileStream: TFileStream;
  FileBuffer: TByteDynArray;
begin
  FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  FileBuffer := nil;
  SetLength(FileBuffer, FileStream.Size);
  FileStream.Read(Pointer(FileBuffer)^, FileStream.Size);
  FileStream.Free;
  Result := TCRC32.Calc(FileBuffer, Length(FileBuffer));
end;

function IndexByGameFilesInfo(FarCry2ExeSize: Integer; FarCry2ExeCRC32: Cardinal; DuniaDllSize: Integer): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := Low(GameFilesInfo) to High(GameFilesInfo) do
  begin
{(*}
    if (FarCry2ExeSize  <> 0) and (GameFilesInfo[i].FarCry2ExeSize  = FarCry2ExeSize)  or
       (FarCry2ExeCRC32 <> 0) and (GameFilesInfo[i].FarCry2ExeCRC32 = FarCry2ExeCRC32) or
       (DuniaDllSize    <> 0) and (GameFilesInfo[i].DuniaDllSize    = DuniaDllSize) then
{*)}
    begin
      Result := i;
      Break;
    end;
  end;
end;

function GetGameVersion(): Integer;
var
  DuniaDllSize: Integer;
  IndexByDuniaDll: Integer;
  FileStream: TFileStream;
  VersionStringOffset: Integer;
  UpdateVersion: array[0..3] of Char;
begin
  Result := 0;
  DuniaDllSize := GetFileSize(DuniaDllName);
  IndexByDuniaDll := IndexByGameFilesInfo(0, 0, DuniaDllSize);
  if (IndexByDuniaDll >= Low(GameFilesInfo)) and (IndexByDuniaDll <= High(GameFilesInfo)) then
    VersionStringOffset := GameFilesInfo[IndexByDuniaDll].VersionStringOffset
  else
    raise Exception.Create(Format('Wrong size of Dunia.dll file (%d). Game version v1.03 supported only.', [DuniaDllSize]));
  FileStream := TFileStream.Create(DuniaDllName, fmOpenRead or fmShareDenyNone);
  FileStream.Seek(VersionStringOffset, soFromBeginning);
  FileStream.ReadBuffer(UpdateVersion, 4);
  FileStream.Free;
  if UpdateVersion <> '1.03' then
    raise Exception.Create('Wrong version of Dunia.dll file. Game version v1.03 supported only.');
  Result := IndexByDuniaDll;
end;

procedure FormOptionsAddSubItems(Nodes: IXMLNodeList; var SubItems: TOptionSubItems);
var
  N: Integer;
  i: Integer;
begin
  if Nodes.Count = 0 then
    Exit;
  for i := 0 to Nodes.Count - 1 do
  begin
    N := Length(SubItems);
    if Nodes[i].NodeName = 'integer' then
    begin
      SetLength(SubItems, N + 1);
      SubItems[N].Key := Nodes[i].Attributes['key'];
      SubItems[N].Name := Nodes[i].Attributes['name'];
      TVarData(SubItems[N].Value).VType := varInteger;
      TVarData(SubItems[N].Default).VType := varInteger;
      try
        SubItems[N].Default := Nodes[i].Attributes['default'];
      except
      end;
    end;
    if Nodes[i].NodeName = 'string' then
    begin
      SetLength(SubItems, N + 1);
      SubItems[N].Key := Nodes[i].Attributes['key'];
      SubItems[N].Name := Nodes[i].Attributes['name'];
      TVarData(SubItems[N].Value).VType := varString;
      TVarData(SubItems[N].Default).VType := varString;
      try
        SubItems[N].Default := Nodes[i].Attributes['default'];
      except
      end;
    end;
  end;
end;

procedure FormOptionsAddItems(Nodes: IXMLNodeList; ParentIndex: Integer = -1);
var
  N: Integer;
  i: Integer;
begin
  if Nodes.Count = 0 then
    Exit;
  for i := 0 to Nodes.Count - 1 do
  begin
    N := Length(OptionItems);
    if Nodes[i].NodeName = 'section' then
    begin
      SetLength(OptionItems, N + 1);
      OptionItems[N].Name := Nodes[i].Attributes['name'];
      OptionItems[N].Description := Nodes[i].Attributes['description'];
      OptionItems[N].ParentIndex := ParentIndex;
      if Nodes[i].HasChildNodes then
        FormOptionsAddItems(Nodes[i].ChildNodes);
    end;
    if Nodes[i].NodeName = 'boolean' then
    begin
      SetLength(OptionItems, N + 1);
      OptionItems[N].Key := Nodes[i].Attributes['key'];
      OptionItems[N].Name := OptionItems[N].Name + Nodes[i].Attributes['name'];
      OptionItems[N].ParentIndex := ParentIndex;
      try
        OptionItems[N].Default := Nodes[i].Attributes['default'];
      except
      end;
      if ParentIndex <> -1 then
      begin
        OptionItems[N].Name := '-' + StringOfChar(' ', 3) + OptionItems[N].Name;
      end;
      OptionItems[N].Description := Nodes[i].Attributes['description'];
      if Nodes[i].HasChildNodes then
        FormOptionsAddSubItems(Nodes[i].ChildNodes, OptionItems[N].OptionSubItems);
      if Nodes[i].HasChildNodes then
        FormOptionsAddItems(Nodes[i].ChildNodes, N);
    end;
  end;
end;

procedure LoadFormOptionsFromXML();
var
  Doc: IXMLDocument;
  ResourceStream: TResourceStream;
begin
  SetLength(OptionItems, 0);
  ResourceStream := TResourceStream.Create(HInstance, 'FormOptions', RT_RCDATA);
  Doc := TXMLDocument.Create(nil);
  Doc.LoadFromStream(ResourceStream, xetUTF_8);
  Doc.Active := True;
  ResourceStream.Free;
  FormOptionsAddItems(Doc.DocumentElement.ChildNodes);
end;

function GetOptionByKey(Key: string): Variant;
begin
  VarClear(Result);
  if Key = 'bJackalTapesFix' then
    Result := Options.bJackalTapesFix;
  if Key = 'bPredecessorTapesUnlock' then
    Result := Options.bPredecessorTapesUnlock;
  if Key = 'bMachetesUnlock' then
    Result := Options.bMachetesUnlock;
  if Key = 'bNoBlinkingItems' then
    Result := Options.bNoBlinkingItems;
  if Key = 'bFOV' then
    Result := Options.bFOV;
  if Key = 'iFOV' then
    Result := Options.iFOV;
  if Key = 'bSkipIntroMovies' then
    Result := CommandLineOptions.bSkipIntroMovies;
  if Key = 'bMaxFps' then
    Result := CommandLineOptions.bMaxFps;
  if Key = 'iMaxFps' then
    Result := CommandLineOptions.iMaxFps;
  if Key = 'bAllWeaponsUnlock' then
    Result := CommandLineOptions.bAllWeaponsUnlock;
  if Key = 'bUnlimitedReliability' then
    Result := CommandLineOptions.bUnlimitedReliability;
  if Key = 'bUnlimitedAmmo' then
    Result := CommandLineOptions.bUnlimitedAmmo;
  if Key = 'bGodMode' then
    Result := CommandLineOptions.bGodMode;
  if Key = 'bZombieAI' then
    Result := CommandLineOptions.bZombieAI;
  if Key = 'bExec' then
    Result := CommandLineOptions.bExec;
  if Key = 'sExec' then
    Result := CommandLineOptions.sExec;
end;

procedure SetOptionByKey(Key: string; Value: Variant);
begin
  if Key = 'bJackalTapesFix' then
    Options.bJackalTapesFix := Value;
  if Key = 'bPredecessorTapesUnlock' then
    Options.bPredecessorTapesUnlock := Value;
  if Key = 'bMachetesUnlock' then
    Options.bMachetesUnlock := Value;
  if Key = 'bNoBlinkingItems' then
    Options.bNoBlinkingItems := Value;
  if Key = 'bFOV' then
    Options.bFOV := Value;
  if Key = 'iFOV' then
    Options.iFOV := Value;
  if Key = 'bSkipIntroMovies' then
    CommandLineOptions.bSkipIntroMovies := Value;
  if Key = 'bMaxFps' then
    CommandLineOptions.bMaxFps := Value;
  if Key = 'iMaxFps' then
    CommandLineOptions.iMaxFps := Value;
  if Key = 'bAllWeaponsUnlock' then
    CommandLineOptions.bAllWeaponsUnlock := Value;
  if Key = 'bUnlimitedReliability' then
    CommandLineOptions.bUnlimitedReliability := Value;
  if Key = 'bUnlimitedAmmo' then
    CommandLineOptions.bUnlimitedAmmo := Value;
  if Key = 'bGodMode' then
    CommandLineOptions.bGodMode := Value;
  if Key = 'bZombieAI' then
    CommandLineOptions.bZombieAI := Value;
  if Key = 'bExec' then
    CommandLineOptions.bExec := Value;
  if Key = 'sExec' then
    CommandLineOptions.sExec := Value;
end;

end.

