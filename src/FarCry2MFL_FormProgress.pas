unit FarCry2MFL_FormProgress;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ComCtrls,
  StdCtrls, ExtCtrls;

type
  TFormProgress = class(TForm)
    ButtonCancel: TButton;
    ProgressBar1: TProgressBar;
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure StartTimer(TimeOut: Integer);
  end;

var
  FormProgress: TFormProgress;

implementation

uses
  FarCry2MFL_Proc;


{$R *.dfm}

procedure TFormProgress.StartTimer(TimeOut: Integer);
begin
  ProgressBar1.Max := TimeOut * 1000 div Timer1.Interval;
  Timer1.Enabled := True;
end;

procedure TFormProgress.Timer1Timer(Sender: TObject);
begin
  ProgressBar1.Position := ProgressBar1.Position + 1;
  if (ProgressBar1.Position = ProgressBar1.Max)
    or (DllLoadingState <> dlsLoading) then
    Close;
end;

end.
