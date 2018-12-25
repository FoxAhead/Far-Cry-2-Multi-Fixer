unit FarCry2MFL_InstallSearch;

interface

type
  TInstallSearch = record
    RKey: string;
    RValue: string;
    Path: string;
  end;

  TInstallSearchs = array[0..5] of TInstallSearch;

const
  InstallSearchs: TInstallSearchs = ((
    RKey: '\SOFTWARE\Ubisoft\Far Cry 2';
    RValue: 'InstallDir';
    Path: 'bin';
    ), (
    RKey: '\SOFTWARE\Wow6432Node\Ubisoft\Far Cry 2';
    RValue: 'InstallDir';
    Path: 'bin';
    ), (
    RKey: '\SOFTWARE\Valve\Steam';
    RValue: 'InstallPath';
    Path: 'steamapps\common\far cry 2\bin';
    ), (
    RKey: '\SOFTWARE\Wow6432Node\Valve\Steam';
    RValue: 'InstallPath';
    Path: 'steamapps\common\far cry 2\bin';
    ), (
    RKey: '\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 19900';
    RValue: 'InstallDir';
    Path: 'bin';
    ), (
    RKey: '\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 19900';
    RValue: 'InstallDir';
    Path: 'bin';
    ));

function TryGetOneInstallLocation(InstallSearch: TInstallSearch): string;

function GetInstallLocation(): string;

implementation

uses
  Registry,
  Windows,
  SysUtils;

function GetInstallLocation(): string;
var
  i: Integer;
  Path: string;
begin
  for i := Low(InstallSearchs) to High(InstallSearchs) do
  begin
    Path := TryGetOneInstallLocation(InstallSearchs[i]);
    if Path <> '' then
    begin
      Result := Path;
      Break;
    end;
  end;
end;

function TryGetOneInstallLocation(InstallSearch: TInstallSearch): string;
var
  Registry: TRegistry;
  Path: string;
begin
  Result := '';
  Registry := TRegistry.Create(KEY_READ);
  Registry.RootKey := HKEY_LOCAL_MACHINE;
  try
    if Registry.OpenKey(InstallSearch.RKey, False) then
    begin
      Path := Registry.ReadString(InstallSearch.RValue);
      if Path <> '' then
      begin
        Path := Path + '\' + InstallSearch.Path;
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

end. 
