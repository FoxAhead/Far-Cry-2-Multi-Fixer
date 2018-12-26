unit FarCry2MF_Options;

interface

type
  PFC2MFOptions = ^TFC2MFOptions;

  TFC2MFOptions = packed record
    bJackalTapesFix: Boolean;
    bPredecessorTapesUnlock: Boolean;
    bMachetesUnlock: Boolean;
    bNoBlinkingItems: Boolean;
    bFOV: Boolean;
    iFOV: Integer;
    bTest1: Boolean;
    bTest2: Boolean;
    Version: Integer;                     // 1 - Steam v1.03, 2 - Retail v1.03
  end;

const
  GAME_VERSION_STEAM = 1;
  GAME_VERSION_RETAIL = 2;

var
  Options: TFC2MFOptions { = (
  bJackalTapesFix: True;
  bPredecessorTapesUnlock: True;
  bMachetesUnlock: True;
  bNoBlinkingItems: True;
  bFOV: False;
  iFOV: 90;
  bTest1: False;
  bTest2: False;
)};
  FC2MFOptions: PFC2MFOptions = Pointer($00403200);

implementation

end.
