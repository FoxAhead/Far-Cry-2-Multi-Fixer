unit FarCry2Types;

interface

const
  GAddr: array[1..2, 1..12] of Cardinal =
    ((
    $1074E465,
    $102E1D15,
    $10048939,
    $10E49D08,                            //"Mesh_Highlight"
    $10504CC0,
    $10504CC6,
    $10234A30,                            //Q_LoadFCB_Item_sub_10234A30
    $10234320,                            //sub_10234320
    $1029741B,                            //ConsoleCommand: call    sub_10291D70
    $10291D70,                            //sub_10291D70
    $10E115B8,                            //"archBlink"
    $10E933B3                             //"gadgets.ObjectiveIcons.SaveDisk"
    ), (
    $10740F55,
    $10048987,
    $10048A09,
    $10DC1A94,
    $104F6B30,
    $104F6B36,
    $102320C0,                            //Q_LoadFCB_Item_sub_102320C0
    $10231980,                            //sub_10231980
    $1029563B,                            //ConsoleCommand: call    sub_1028F9E0
    $1028F9E0,                            //sub_1028F9E0
    $10D8B3B0,
    $10E0AFC2                             
    ));

implementation

end.
