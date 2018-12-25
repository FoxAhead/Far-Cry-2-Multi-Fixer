unit FarCry2MF_Proc;

interface

procedure WriteMemory(HProcess: THandle; Address: Integer; Opcodes: array of Byte; ProcAddress: Pointer = nil);

implementation

uses
  Windows;

procedure WriteMemory(HProcess: THandle; Address: Integer; Opcodes: array of Byte; ProcAddress: Pointer);
var
  SizeOP: Integer;
  BytesWritten: Cardinal;
  Offset: Integer;
  LastError: Cardinal;
  OldProtect: Cardinal;
begin
  SizeOP := SizeOf(Opcodes);
  if SizeOP > 0 then begin
    VirtualProtect(Pointer(Address), SizeOP, PAGE_EXECUTE_READWRITE, OldProtect);
    WriteProcessMemory(HProcess, Pointer(Address), @Opcodes, SizeOP, BytesWritten);
    VirtualProtect(Pointer(Address), SizeOP, OldProtect, OldProtect);
  end;
  if ProcAddress <> nil then
  begin
    Offset := Integer(ProcAddress) - Address - 4 - SizeOP;
    if not WriteProcessMemory(HProcess, Pointer(Address + SizeOP), @Offset, 4, BytesWritten) then
      LastError := GetLastError();
  end;
end;

end.
