unit formModelSelect;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, RzButton, RzPanel, RzLstBox, System.IniFiles,
  DefCommon{, LogicVh};

type
  TfrmSelectModel = class(TForm)
    Panel_Header: TRzPanel;
    RzPanel1: TRzPanel;
    btnCancel: TRzBitBtn;
    btnOk: TRzBitBtn;
    RzGroupBox5: TRzGroupBox;
    lstModel: TRzListBox;
    cbbModelType: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ModelListBoxKeyPress(Sender: TObject; var Key: Char);
    procedure IntegerKeyPress(Sender: TObject; var Key: Char);
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure lstModelDblClick(Sender: TObject);
    procedure cbbModelTypeClick(Sender: TObject);
  private
    { Private declarations }

    procedure Load_Model(nIdx : Integer);
    procedure FindItemToListbox(tList: TRzListbox; sItem: string);
    procedure SetModelType;
//    function CheckModelDownload(sModelName : string) : Boolean;
  public
    { Public declarations }
    m_bClickOkBtn : Boolean;
  end;

var
  frmSelectModel: TfrmSelectModel;

implementation

uses
  CommonClass;

{$R *.dfm}

procedure TfrmSelectModel.Load_Model(nIdx : Integer);
var
  nRstD    : Integer;
  srD      : TSearchrec;
  sModel, sModelType, sTarget  : string;
begin
  lstModel.Clear;
  lstModel.DisableAlign;

  sTarget := cbbModelType.Items[nIdx];
  nRstD := FindFirst(Common.Path.MODEL+ '*.*',faDirectory, srD);
  while nRstD = 0 do begin
    if not ((Trim(srD.Name) = '.') or (Trim(srD.Name) = '..') or ( (srD.Attr and faDirectory) = 0)) then begin
//      lstModel.Items.Add(Copy(srD.Name, 1, pos('.', srD.Name) - 1));
      sModel  := srD.Name;
      if nIdx <> 0 then begin
        sModelType := Common.GetModelType(2,sModel);
        if sTarget = sModelType then lstModel.Items.Add(sModel);
      end
      else begin
        lstModel.Items.Add(sModel);
      end;
    end;
    nRstD := FindNext(srD);
  end;
  FindClose(srD);
  lstModel.Sorted := True;

  if lstModel.Items.Count > 0 then begin
    FindItemToListbox(lstModel, Common.SystemInfo.TestModel);
  end;
  lstModel.EnableAlign;
end;

procedure TfrmSelectModel.FindItemToListbox(tList: TRzListbox; sItem: string);
var
  i : Integer;
begin
  for i := 0 to tList.Items.Count - 1 do begin
    if tList.Items.Strings[i] = sItem then begin
      tList.ItemIndex := i;
      Break;
    end;
  end;
end;

procedure TfrmSelectModel.FormCreate(Sender: TObject);
begin

  SetModelType;
  Load_Model(cbbModelType.ItemIndex);
  m_bClickOkBtn := False;
end;



procedure TfrmSelectModel.FormActivate(Sender: TObject);
begin
  if lstModel.CanFocus then lstModel.SetFocus;
end;

procedure TfrmSelectModel.ModelListBoxKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
    btnOkClick(nil);
end;

procedure TfrmSelectModel.SetModelType;
var
  srD       : TSearchrec;
  nRstD, i     : Integer;
  sModelType    : string;
  bCheck        : boolean;
begin
  cbbModelType.Clear;
  cbbModelType.Items.Add('ALL Model');

  nRstD := FindFirst(Common.Path.MODEL+ '*.*',faDirectory, srD);
  try
    while nRstD = 0 do begin
      if not ((Trim(srD.Name) = '.') or (Trim(srD.Name) = '..') or ( (srD.Attr and faDirectory) = 0)) then begin
  //      lstModel.Items.Add(Copy(srD.Name, 1, pos('.', srD.Name) - 1));
        sModelType :=  Common.GetModelType(2,srD.Name);
        if Trim(sModelType) <> '' then begin

          bCheck := True;
          for i := 1 to Pred(cbbModelType.Items.Count) do begin
            if Trim(cbbModelType.Items[i]) = sModelType  then begin
              bCheck := False;
              Break;
            end;
          end;
          // �ߺ��Ǵ� Type�� ������ ���� �߰� ����.
          if bCheck then cbbModelType.Items.Add(sModelType);
        end;
      end;
      nRstD := FindNext(srD);
    end;
  finally
    FindClose(srD);
  end;
  sModelType := Common.GetModelType(2,Common.SystemInfo.TestModel);
  for i := 1 to Pred(cbbModelType.Items.Count) do begin
    if cbbModelType.Items[i] = sModelType then begin
      cbbModelType.ItemIndex := i;
      Break;
    end;
  end;
end;

procedure TfrmSelectModel.IntegerKeyPress(Sender: TObject; var Key: Char);
begin
  if not (AnsiChar(Key) in ['0'..'9', #8, #13]) then Key := #0;
end;

procedure TfrmSelectModel.btnOkClick(Sender: TObject);
var
  fName, sScriptPath : String;
begin
  if lstModel.ItemIndex >= 0 then begin
    fName := lstModel.Items[lstModel.Itemindex];
    Common.SystemInfo.TestModel := Trim(fName);
    Common.SaveSystemInfo;
    Common.LoadModelInfo(Trim(fName));
    m_bClickOkBtn := True;
  end;
  Close;
end;

procedure TfrmSelectModel.cbbModelTypeClick(Sender: TObject);
begin
  Load_Model(cbbModelType.ItemIndex);
end;

procedure TfrmSelectModel.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSelectModel.lstModelDblClick(Sender: TObject);
begin
  btnOkClick(nil);
end;

end.
