unit FarCry2MFL_FormOptions;

interface

uses
  CheckLst,
  Classes,
  Controls,
  Forms,
  StdCtrls,
  SysUtils,
  FarCry2MFL_Proc;

type
  TFormOptions = class(TForm)
    CheckListBox1: TCheckListBox;
    ButtonOK: TButton;
    ButtonCancel: TButton;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure CheckListBox1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ButtonOKClick(Sender: TObject);
    procedure CheckListBox1ClickCheck(Sender: TObject);
  private
    { Private declarations }
    Labels: array of TLabel;
    Edits: array of TEdit;
    EditsOwnerIndex: Integer;
    OKPressed: Boolean;
    procedure FreeEdits();
  public
    { Public declarations }
    procedure CopyOptionsToBackend();
    procedure CopyBackendToOptions();
    procedure CopyFrontendToBackend();
    procedure CopyBackendToFrontend();
    function ValidateInput(Index: Integer): Boolean;
  end;

implementation

uses
  Graphics,
  Variants;

{$R *.dfm}

procedure TFormOptions.FormCreate(Sender: TObject);
var
  i: Integer;
begin

  CheckListBox1.Clear();

  for i := 0 to High(OptionItems) do
  begin
    CheckListBox1.Items.Append(OptionItems[i].Name);
    if OptionItems[i].Key = '' then
      CheckListBox1.Header[i] := True;
  end;

  CopyOptionsToBackend();
  CopyBackendToFrontend();
end;

procedure TFormOptions.CheckListBox1Click(Sender: TObject);
var
  N: Integer;
  M: Integer;
  i: Integer;
  EditsTop: Integer;
begin
  if not ValidateInput(EditsOwnerIndex) then
  begin
    CheckListBox1.ItemIndex := EditsOwnerIndex;
    Exit;
  end;

  N := CheckListBox1.ItemIndex;
  if N >= 0 then
  begin
    Memo1.Text := OptionItems[N].Description;
    FreeEdits();

    M := Length(OptionItems[N].OptionSubItems);
    SetLength(Labels, M);
    SetLength(Edits, M);
    EditsTop := CheckListBox1.Top + CheckListBox1.Height - M * 27 + 6;
    Memo1.Height := CheckListBox1.Height - M * 27;
    for i := 0 to M - 1 do
    begin
      Edits[i] := TEdit.Create(Self);
      Edits[i].Parent := Self;
      Edits[i].Visible := True;
      Edits[i].Left := Memo1.Left;
      Edits[i].Top := EditsTop + i * 27;
      Edits[i].Height := 21;
      case VarType(OptionItems[N].OptionSubItems[i].Value) of
        varInteger, varSmallint, varByte, varWord, varLongWord:
          Edits[i].Width := 85;
        varString:
          Edits[i].Width := 185;
      end;
      Edits[i].Text := OptionItems[N].OptionSubItems[i].Value;
      if OptionItems[N].ParentIndex <> -1 then
        Edits[i].Enabled := OptionItems[OptionItems[N].ParentIndex].Checked;
      Labels[i] := TLabel.Create(Self);
      Labels[i].Parent := Self;
      Labels[i].Visible := True;
      Labels[i].Left := Edits[i].Left + Edits[i].Width + 4;
      Labels[i].Top := Edits[i].Top + 4;
      Labels[i].Caption := OptionItems[N].OptionSubItems[i].Name;
    end;
    EditsOwnerIndex := N;
  end;

end;

procedure TFormOptions.FreeEdits;
var
  i: Integer;
begin
  for i := Low(Edits) to High(Edits) do
    if Edits[i] <> nil then
      FreeAndNil(Edits[i]);
  SetLength(Edits, 0);
  for i := Low(Labels) to High(Labels) do
    if Labels[i] <> nil then
      FreeAndNil(Labels[i]);
  SetLength(Labels, 0);
end;

function TFormOptions.ValidateInput(Index: Integer): Boolean;
var
  M: Integer;
  i: Integer;
begin
  Result := True;
  if Length(Edits) > 0 then
  begin
    M := Length(OptionItems[Index].OptionSubItems);
    for i := 0 to M - 1 do
    begin
      try
        OptionItems[Index].OptionSubItems[i].Value := VarAsType(Edits[i].Text, VarType(OptionItems[Index].OptionSubItems[i].Value));
        Edits[i].Font.Color := clWindowText;
      except
        Edits[i].Font.Color := clRed;
        Result := False;
      end;
    end;
  end;
end;

procedure TFormOptions.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if OKPressed then
    if not ValidateInput(EditsOwnerIndex) then
    begin
      OKPressed := False;
      CanClose := False;
    end
    else
      CopyBackendToOptions();
end;

procedure TFormOptions.ButtonOKClick(Sender: TObject);
begin
  OKPressed := True;
end;

procedure TFormOptions.CheckListBox1ClickCheck(Sender: TObject);
begin
  CopyFrontendToBackend();
  CopyBackendToFrontend();
end;

procedure TFormOptions.CopyOptionsToBackend;
var
  i, j: Integer;
begin
  for i := 0 to High(OptionItems) do
  begin
    OptionItems[i].Checked := GetOptionByKey(OptionItems[i].Key);
    for j := 0 to High(OptionItems[i].OptionSubItems) do
      OptionItems[i].OptionSubItems[j].Value := GetOptionByKey(OptionItems[i].OptionSubItems[j].Key);
  end;
end;

procedure TFormOptions.CopyBackendToOptions;
var
  i, j: Integer;
begin
  for i := 0 to High(OptionItems) do
  begin
    SetOptionByKey(OptionItems[i].Key, OptionItems[i].Checked);
    for j := 0 to High(OptionItems[i].OptionSubItems) do
      SetOptionByKey(OptionItems[i].OptionSubItems[j].Key, OptionItems[i].OptionSubItems[j].Value);
  end;
end;

procedure TFormOptions.CopyFrontendToBackend;
var
  i: Integer;
begin
  for i := 0 to CheckListBox1.Count - 1 do
  begin
    if CheckListBox1.Header[i] = False then
    begin
      OptionItems[i].Checked := CheckListBox1.Checked[i];
    end;
  end;
end;

procedure TFormOptions.CopyBackendToFrontend;
var
  i, j: Integer;
begin
  for i := 0 to High(OptionItems) do
  begin
    if CheckListBox1.Header[i] = False then
      CheckListBox1.Checked[i] := OptionItems[i].Checked;
    if OptionItems[i].ParentIndex <> -1 then
    begin
      CheckListBox1.ItemEnabled[i] := OptionItems[OptionItems[i].ParentIndex].Checked;
    end;
  end;
  CheckListBox1.Repaint();
end;

end.

