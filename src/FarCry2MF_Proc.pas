unit FarCry2MF_Proc;

interface

var
  GErrorCode: Integer;
  GLastError: Integer;

procedure RaiseWithLastError(ErrorCode: Integer);

procedure WriteMemory(HProcess: THandle; Address: Integer; Opcodes: array of Byte; ProcAddress: Pointer = nil);

implementation

uses
  Windows,
  SysUtils;

procedure RaiseWithLastError(ErrorCode: Integer);
begin
  GErrorCode := ErrorCode;
  GLastError := GetLastError();
  raise Exception.Create('');
end;

procedure WriteMemory(HProcess: THandle; Address: Integer; Opcodes: array of Byte; ProcAddress: Pointer);
var
  SizeOP: Integer;
  BytesWritten: Cardinal;
  Offset: Integer;
  OldProtect: Cardinal;
begin
  SizeOP := SizeOf(Opcodes);
  if SizeOP > 0 then
  begin
    if not VirtualProtect(Pointer(Address), SizeOP, PAGE_EXECUTE_READWRITE, OldProtect) then
      RaiseWithLastError(1);
    if not WriteProcessMemory(HProcess, Pointer(Address), @Opcodes, SizeOP, BytesWritten) then
      RaiseWithLastError(2);
    if not VirtualProtect(Pointer(Address), SizeOP, OldProtect, OldProtect) then
      RaiseWithLastError(3);
  end;
  if ProcAddress <> nil then
  begin
    Offset := Integer(ProcAddress) - Address - 4 - SizeOP;
    if not WriteProcessMemory(HProcess, Pointer(Address + SizeOP), @Offset, 4, BytesWritten) then
      RaiseWithLastError(4);
  end;
end;

end.
