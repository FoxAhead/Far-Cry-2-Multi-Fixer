library FarCry2MF;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  Messages,
  SysUtils,
  Windows,
  FarCry2Types in 'FarCry2Types.pas',
  FarCry2Proc in 'FarCry2Proc.pas',
  FarCry2MF_Types in 'FarCry2MF_Types.pas',
  FarCry2MF_Options in 'FarCry2MF_Options.pas',
  FarCry2MF_Proc in 'FarCry2MF_Proc.pas';

{$R *.res}

var
  GVer: Integer;
  GfFOV: Single;
  GfFOVRet: Integer;

procedure SendMessageToLoader(WParam: Integer; LParam: Integer); stdcall;
var
  HWindow: HWND;
begin
  HWindow := FindWindow('TForm1', 'Far Cry 2 Multi Fixer Launcher');
  if HWindow > 0 then
  begin
    PostMessage(HWindow, WM_APP + 1, WParam, LParam);
  end;
end;

//--------------------------------------------------------------------------------------------------
//
//   Patches Section
//
//--------------------------------------------------------------------------------------------------

{$O-}

procedure PatchCalcFov; register;
asm
    movss xmm0, GfFOV
    push  GfFOVRet
    ret
end;

{$O+}

//--------------------------------------------------------------------------------------------------
//
//   Initialization Section
//
//--------------------------------------------------------------------------------------------------

procedure Attach(HProcess: Cardinal);
begin
  GVer := FC2MFOptions.Version;
  if FC2MFOptions.bJackalTapesFix then
  begin
    WriteMemory(HProcess, GAddr[GVer, 1], [$14]);
  end;
  if FC2MFOptions.bPredecessorTapesUnlock then
  begin
    case GVer of
      GAME_VERSION_STEAM:
        WriteMemory(HProcess, GAddr[GVer, 2], [$EB, $0E]);
      GAME_VERSION_RETAIL:
        WriteMemory(HProcess, GAddr[GVer, 2], [$B0, $01]);
    end;
  end;
  if FC2MFOptions.bMachetesUnlock then
  begin
    WriteMemory(HProcess, GAddr[GVer, 3], [$B0, $01]);
  end;
  if FC2MFOptions.bNoBlinkingItems then
  begin
    WriteMemory(HProcess, GAddr[GVer, 4], [$2E]);
  end;
  if FC2MFOptions.bFOV then
  begin
    WriteMemory(HProcess, GAddr[GVer, 5], [OP_NOP, OP_JMP], @PatchCalcFov);
    GfFOV := FC2MFOptions.iFOV;
    GfFOVRet := GAddr[GVer, 6];
  end;
  {if FC2MFOptions.bTest1 then
  begin
    WriteMemory(HProcess, $10F007F0, [$00, $00, $00, $00, $00, $00, $00, $00]);
  end;
  if FC2MFOptions.bTest2 then
  begin
    WriteMemory(HProcess, $10ED8EDC, [$20, $41]);
  end;}
end;

procedure DllMain(Reason: Integer);
var
  HProcess: Cardinal;
begin
  case Reason of
    DLL_PROCESS_ATTACH:
      begin
        HProcess := OpenProcess(PROCESS_ALL_ACCESS, False, GetCurrentProcessId());
        try
          Attach(HProcess);
          SendMessageToLoader(0, 0);
        except
          on E: Exception do
          begin
            SendMessageToLoader(-1, GErrorCode);
            SendMessageToLoader(-1, GLastError);
            SendMessageToLoader(-1, -1);
          end;
        end;
        CloseHandle(HProcess);
      end;
    DLL_PROCESS_DETACH:
      ;
  end;

end;

begin
  DllProc := @DllMain;
  DllProc(DLL_PROCESS_ATTACH);
end.
