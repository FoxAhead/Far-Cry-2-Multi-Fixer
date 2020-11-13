unit FarCry2MFL_FormMods;

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
  StdCtrls,
  CheckLst,
  ExtCtrls;

type
  TFormMods = class(TForm)
    ButtonOK: TButton;
    ButtonCancel: TButton;
    CheckListBox1: TCheckListBox;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Edit2: TEdit;
    ButtonAdd: TButton;
    ButtonDel: TButton;
    CheckBox1: TCheckBox;
    Button5: TButton;
    procedure ButtonOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CheckListBox1ClickCheck(Sender: TObject);
    procedure CheckListBox1DragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure CheckListBox1DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ButtonAddClick(Sender: TObject);
    procedure ButtonDelClick(Sender: TObject);
    procedure CheckListBox1Click(Sender: TObject);
  private
    { Private declarations }
    OKPressed: Boolean;
  public
    { Public declarations }
  end;

  TBackendModItem = record
    name: string;
    path: string;
  end;

var
  BackendModItems: array of TBackendModItem;

implementation

{$R *.dfm}

procedure TFormMods.FormCreate(Sender: TObject);
begin
  //CheckListBox1.Clear();
end;

procedure TFormMods.ButtonOKClick(Sender: TObject);
begin
  OKPressed := True;
end;

procedure TFormMods.CheckListBox1ClickCheck(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to CheckListBox1.Count - 1 do
  begin
    if i <> CheckListBox1.ItemIndex then
      CheckListBox1.Checked[i] := False;
  end;

end;

procedure TFormMods.CheckListBox1DragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := Source is TCheckListBox;
end;

procedure TFormMods.CheckListBox1DragDrop(Sender, Source: TObject; X, Y: Integer);
begin
 //
end;

procedure TFormMods.ButtonAddClick(Sender: TObject);
begin
  CheckListBox1.Items.Append('');
end;

procedure TFormMods.ButtonDelClick(Sender: TObject);
var
  SelectedIndex: Integer;
begin
  SelectedIndex := CheckListBox1.ItemIndex;
  if SelectedIndex >= 0 then
  begin
    CheckListBox1.Items.Delete(SelectedIndex);
    CheckListBox1.ItemIndex := SelectedIndex;
  end;
end;

procedure TFormMods.CheckListBox1Click(Sender: TObject);
var
  N: Integer;
begin
  N := CheckListBox1.ItemIndex;
  if N >= 0 then
  begin

  end;
end;

end.

