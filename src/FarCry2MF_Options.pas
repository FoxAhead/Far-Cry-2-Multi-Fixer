unit FarCry2MF_Options;

interface

type
  PFC2MFOptions = ^TFC2MFOptions;

  TFC2MFOptions = packed record
    Version: Integer;
    bJackalTapesFix: Boolean;
    bPredecessorTapesUnlock: Boolean;
    bMachetesUnlock: Boolean;
    bNoBlinkingItems: Boolean;
    bFOV: Boolean;
    iFOV: Integer;
    bSkipIntroMovies: Boolean;
    bMaxFps: Boolean;
    iMaxFps: Integer;
    bAllWeaponsUnlock: Boolean;
    bUnlimitedReliability: Boolean;
    bUnlimitedAmmo: Boolean;
    bGodMode: Boolean;
    bZombieAI: Boolean;
  end;

const
  GAME_VERSION_STEAM = 1;
  GAME_VERSION_RETAIL = 2;

var
  Options: TFC2MFOptions;
  FC2MFOptions: PFC2MFOptions = Pointer($00403200);

implementation

end.
