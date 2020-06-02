unit FarCry2MFL_InstallSearch;

interface

type
  TInstallSearch = record
    RKey: string;
    RValue: string;
    Path: string;
  end;

  TInstallSearchs = array[0..4] of TInstallSearch;

const
  InstallSearchs: TInstallSearchs = ((
    RKey: '\Ubisoft\Far Cry 2';
    RValue: 'InstallDir';
    Path: 'bin';
  ), (
    RKey: '\Valve\Steam';
    RValue: 'InstallPath';
    Path: 'steamapps\common\far cry 2\bin';
  ), (
    RKey: '\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 19900';
    RValue: 'InstallLocation';
    Path: 'bin';
  ), (
    RKey: '\Ubisoft\Launcher\Installs\85';
    RValue: 'InstallDir';
    Path: 'bin';
  ), (
    RKey: '\Microsoft\Windows\CurrentVersion\Uninstall\Uplay Install 85';
    RValue: 'InstallLocation';
    Path: 'bin';
  ));

function GetInstallLocation(): string;

function TryGetOneInstallLocation(Prefix: string; InstallSearch: TInstallSearch): string;

function TranslateChar(const Str: string; FromChar, ToChar: Char): string;

function UnixPathToDosPath(const Path: string): string;

implementation

uses
  Registry,
  SysUtils,
  Windows;

function GetInstallLocation(): string;
var
  i: Integer;
  Path: string;
begin
  Result := '';
  for i := Low(InstallSearchs) to High(InstallSearchs) do
  begin
    Path := TryGetOneInstallLocation('\SOFTWARE', InstallSearchs[i]);
    if Path = '' then
      Path := TryGetOneInstallLocation('\SOFTWARE\Wow6432Node', InstallSearchs[i]);
    if Path <> '' then
    begin
      Result := Path;
      Break;
    end;
  end;
end;

function TryGetOneInstallLocation(Prefix: string; InstallSearch: TInstallSearch): string;
var
  Registry: TRegistry;
  Path: string;
begin
  Result := '';
  Registry := TRegistry.Create(KEY_READ);
  Registry.RootKey := HKEY_LOCAL_MACHINE;
  try
    if Registry.OpenKey(Prefix + InstallSearch.RKey, False) then
    begin
      Path := Registry.ReadString(InstallSearch.RValue);
      if Path <> '' then
      begin
        Path := ExcludeTrailingPathDelimiter(UnixPathToDosPath(Path)) + '\' + InstallSearch.Path;
        if DirectoryExists(Path) then
        begin
          Result := Path;
        end;
      end;
    end;
  finally
    Registry.Free;
  end;
end;

function TranslateChar(const Str: string; FromChar, ToChar: Char): string;
var
  I: Integer;
begin
  Result := Str;
  for I := 1 to Length(Result) do
    if Result[I] = FromChar then
      Result[I] := ToChar;
end;

function UnixPathToDosPath(const Path: string): string;
begin
  Result := TranslateChar(Path, '/', '\');
end;

end.
 
