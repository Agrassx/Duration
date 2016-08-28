unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Samples.Spin,
  Vcl.Grids, Vcl.ComCtrls, StrUtils, Math, Vcl.Menus, IniFiles;

type
  HeatRow = record
    check: TCheckBox;
    startTemp: TEdit;
    endTemp: TEdit;
    agentTemp: TEdit;
    selfHeat: TEdit;
  end;
  BatchSize = record
    min: extended;
    max: extended;
  end;
  FlowFact = record
    InpStr: extended;   //Расходные коэффициенты вх потоков
    AddStr: extended;
    OutStr: extended;
  end;
  ExpFact = record
    AddStr: extended;
    InpStr: extended;
  end;
  DSht = record
    AddStr, Unload, Raw: extended;
  end;
  Heat = record
    startTemp: extended;
    endTemp: extended;
    agentTemp: extended;
    selfHeat: extended;
  end;
  Cool = record
    startTemp: extended;
    endTemp: extended;
    agentTemp: extended;
    selfCool: extended;
  end;
  HeatCapacity = record
    ReactionMass, Machine : extended;
  end;
  FillFactor = record
    upper, lower: extended;
  end;
  Capacity = record
    D, H, V: extended;
  end;
  machine = record
    m, V: extended;
  end;
  limitSize = record
    left, right: extended;
  end;
  RealFillFactor = record
    AddStr, InpStr, Raw ,Real: extended;
  end;
  product = record
    pBatchSize : extended;
    StepMapIndex: extended;
    sizelimit: limitSize;
    pMachine: machine;
    DemUnit: limitsize;
    pRealFillFactor: RealFillFactor;
    VolumeInputStr: extended;
    VolumeAddStr: extended;
    VolumeRawStr: extended;
    pCapacityForAddStr: Capacity;
    pCapacityForRawStr: Capacity;
    durationDownloadInputStr:extended;
    durationDownloadAddStr:extended;
    durationUploadOutStr:extended;
    durationHeat: extended;
    durationCool: extended;
    durationChemicalReact: extended;
    durationOverall: extended;
  end;

  Matrix = array of array of extended;
  StrMatrix = array of array of string;
  intMatrix = array of array of integer;
  TForm1 = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    GroupBox9: TGroupBox;
    Label18: TLabel;
    Capacity: TStringGrid;
    SpinEdit2: TSpinEdit;
    GroupBox8: TGroupBox;
    Label17: TLabel;
    Label67: TLabel;
    Apparatus: TStringGrid;
    SpinEdit1: TSpinEdit;
    EditRatioV_H: TEdit;
    Button2: TButton;
    TabSheet2: TTabSheet;
    GroupBox14: TGroupBox;
    GroupBox15: TGroupBox;
    GroupBox17: TGroupBox;
    Button4: TButton;
    Button5: TButton;
    TabSheet3: TTabSheet;
    Button1: TButton;
    Расчитать: TButton;
    GroupBox18: TGroupBox;
    StringGrid1: TStringGrid;
    GroupBox1: TGroupBox;
    SpinEdit3: TSpinEdit;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    StringGrid2: TStringGrid;
    StringGrid3: TStringGrid;
    Label1: TLabel;
    TabSheet4: TTabSheet;
    GroupBox4: TGroupBox;
    StringGrid4: TStringGrid;
    GroupBox5: TGroupBox;
    StringGrid5: TStringGrid;
    GroupBox6: TGroupBox;
    StringGrid6: TStringGrid;
    StringGrid11: TStringGrid;
    StringGrid12: TStringGrid;
    Button6: TButton;
    StringGrid13: TStringGrid;
    GroupBox7: TGroupBox;
    StringGrid14: TStringGrid;
    Button7: TButton;
    RichEdit1: TRichEdit;
    ScrollBox1: TScrollBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    GroupBox11: TGroupBox;
    ScrollBox2: TScrollBox;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    Label8: TLabel;
    Label9: TLabel;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure CheckBoxClickHeat(Sender: TObject);
    procedure CheckBoxClickCool(Sender: TObject);
    procedure SpinEdit3Change(Sender: TObject);
    procedure SpinEdit2Change(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure РасчитатьClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  rowListHeat:       array of HeatRow;
  rowListCool:       array of HeatRow;
  productsBatchSize: array of BatchSize;            //Размеры партии
  NumbOfProduct: integer;
  DensInpStr:      array of extended;           //Плотности входных потоков
  DensAddStr:      array of extended;          //Плотности добавляемых потоков
  DensRaw:         array of extended;            //Плотность сырья
  productFlowFact: array of FlowFact; // Расходные коэфициенты
  productExpFact:  array of ExpFact;
  pDSht:           array of DSht;
  productHeat:     array of Heat;
  productCool:     array of Cool;
  productHeatCapacity: array of HeatCapacity;
  heatTransfer:    array of extended;
  durationChemicalReact: array of extended;
  machFillFactor: array of FillFactor;
  capacityFillFactor: array of FillFactor;
  pCapacity: array of Capacity;
  pMachine: array of Machine;
  products: array of product;
  mainEqipment: product;


  //RealFillFactor:extended;   //Реальные коэфициенты заполнения
  StepMapInd:    extended;    //Постадийные материальные индексы
  DemUnit: array of extended;      //Размеры аппарата
  DispMachine: extended;      //объем выбранного аппарата
  VCapacityAddStrLimit,VCapacityRawLimit: array of extended; //пределы объема мерника для доб потоков и сырья соотв.
  VCapacityAddStr, VCapacityRaw: extended; // Объем выбранного мерника для доп потокa и сырья соотв.
  HCapacityAddStr, HCapacityRaw: extended; // Высота мерника для сырья и доп потока соответственно
  DCapacityAddStr, DCapacityRaw, DMachine: extended; // Диаметры -//-
   //Реальные коээфциенты заполнения для аппарата доп. и сырья
  Duration: array of integer; //Длительности

  DurationHeat,DurationCool:extended;
  MPHeat,MPCool:extended;
  SurfaceTrans:extended;

implementation

{$R *.dfm}

function CheckString(str: string): boolean;
var i: integer;
begin
 result := true;
 if str = '' then
  begin
    result := false;
    exit;
  end;
 for i := 1 to Length(str) do
  if not (str[i] in ['0'..'9', ';', ',', '.']) then
  begin
   result := false;
   exit;
  end;
end;

procedure Split(const Delimiter: Char; Input: string; const Strings: TStrings);
begin
   Assert(Assigned(Strings));
   Strings.Clear;
   Strings.Delimiter := Delimiter;
   Strings.DelimitedText := Input;
end;

function createCheckBox(Sender: TCheckBox; i: integer; Parent: TWinControl;
                            Form: TForm) : TCheckBox;
begin
   Sender := TCheckBox.Create(Form);
   Sender.Caption := '  '+IntToStr(i+1)+' Прод.';
   Sender.Height := 25;
   Sender.Width := 70;
   if i = 0 then
      Sender.top := 40
   else
      Sender.top := 40*(i+1);
   Sender.Left := 20;
   Sender.Parent := Parent;
   Result := Sender;
end;

function changeEnbledTedit(sender: TEdit; status: boolean) : TEdit;
begin
  if status then
    sender.Font.Color := clWindow
  else
    sender.Font.Color := clBlack;

  sender.Enabled := status;
  result := sender;
end;

function setEditOfHeatRow(Sender: TEdit; i: integer; number: integer;
                            Parent: TWinControl; Form: TForm) : TEdit;
begin
   Sender := TEdit.Create(Form);
   Sender.Height := 20;
   Sender.Width := 80;
//   Sender
   if i = 0 then
      Sender.top := 40
   else
      Sender.top := 40*(i+1);
   if number = 1 then
      Sender.Left := 90*(number) + 60*(number-1)
   else
      Sender.Left := 30+ 50*(number) + 60*(number-1);
   Sender.Parent := Parent;
   if number < 4 then
    Sender.Enabled := false
   else
    Sender.Enabled := true;
   Result := Sender;
end;

function getCheckBoxNumber(Sender: TCheckBox; rowList: array of HeatRow) : Integer;
var
  i: Integer;
begin
  for i := 0 to length(rowList) do
  begin
    if Sender.Equals(rowList[i].check) then
    begin
      Result := i;
      exit;
    end;
  end;
end;

function getVolume(ExpFactAddStr, maxBatchSize, DensAddStr:real):real;
begin
 result:= RoundTo(ExpFactAddStr*maxBatchSize/DensAddStr,-3);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  RichEdit1.Clear;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  i: Integer;
begin

  for i := 0 to SpinEdit3.Value - 1 do
  begin
    if not CheckString(StringGrid1.Cells[1, i + 1]) then
    begin
      ShowMessage('Таблица "Размеры партиий продуктов" заполнена неверно или неполностью');
      exit;
    end;

    if not CheckString(StringGrid2.Cells[1,i + 1]) then
    begin
      ShowMessage('Таблица "Плотность входных потоков" заполнена неверно или неполностью');
      exit;
    end;

    if not CheckString(StringGrid3.Cells[1,i + 1]) then
    begin
      ShowMessage('Таблица "Плотность доп. потоков" заполнена неверно или неполностью');
      exit;
    end;

    if not CheckString(StringGrid4.Cells[1,i + 1]) or not CheckString(StringGrid4.Cells[2,i + 1])
        or not CheckString(StringGrid4.Cells[3,i + 1]) then
    begin
      ShowMessage('Таблица "Коэффициенты расхода" заполнена неверно или неполностью');
      exit;
    end;

    if not CheckString(StringGrid5.Cells[2,i + 1]) or not CheckString(StringGrid5.Cells[1,i + 1]) then
    begin
      ShowMessage('Таблица "расходные коэффициенты" заполнена неверно или неполностью');
      exit;
    end;

    if not CheckString(StringGrid6.Cells[3,i + 1]) or not CheckString(StringGrid6.Cells[1,i + 1])
        or not CheckString(StringGrid6.Cells[2,i + 1]) then
    begin
      ShowMessage('Таблица "Диаметры штуцеров" заполнена неверно или неполностью');
      exit;
    end;
  end;
  PageControl1.SelectNextPage(true);
end;

procedure TForm1.Button6Click(Sender: TObject);
var i: integer;
begin
   for i := 0 to SpinEdit3.Value - 1 do
  begin
   if rowListHeat[i].check.Checked then
      begin
        if not CheckString(rowListHeat[i].startTemp.Text) then
          begin
            ShowMessage('Поле "Начальная температура нагревания" заполнено неверно или не заполнено');
            exit;
          end;

        if not CheckString(rowListHeat[i].endTemp.Text) then
          begin
            ShowMessage('Поле "Конечная температура нагревания" заполнено неверно или не заполнено');
            exit;
          end;

        if not CheckString(rowListHeat[i].agentTemp.Text) then
          begin
            ShowMessage('Поле "Температура теплоносителя" заполнена неверно или не заполнено');
            exit;
          end;
      end
    else
      begin
        if not CheckString(rowListHeat[i].selfHeat.Text) then
          begin
            ShowMessage('Поле "Длительность самонагревания" заполнена неверно или не заполнено');
            exit;
          end;
      end;

    if rowListCool[i].check.Checked then
      begin
        if not CheckString(rowListCool[i].startTemp.Text) then
          begin
            ShowMessage('Поле "Начальная температура охлаждения" заполнена неверно или не заполнено');
            exit;
          end;
        if not CheckString(rowListCool[i].endTemp.Text) then
          begin
            ShowMessage('Поле "Конечная температура охлаждения" заполнена неверно или не заполнено');
            exit;
          end;

        if not CheckString(rowListHeat[i].agentTemp.Text) then
          begin
            ShowMessage('Поле "Температура хладагента" заполнена неверно или не заполнено');
            exit;
          end;
      end
    else
      begin
        if not CheckString(rowListCool[i].selfHeat.Text) then
          begin
            ShowMessage('Поле "Длительность самоохлаждения" заполнена неверно или не заполнено');
            exit;
          end;
      end;
  end;
  PageControl1.SelectNextPage(true);
end;

procedure TForm1.Button7Click(Sender: TObject);
var i:integer;
begin
  for i := 0 to SpinEdit3.Value - 1 do
    begin
      if not (CheckString(StringGrid14.Cells[1,i + 1])) or not (CheckString(StringGrid14.Cells[2,i + 1])) then
      begin
        ShowMessage('Таблица "Коэффициенты заполнения" заполнена неверно или не заполнена');
        exit;
      end;
    end;
for i := 1 to Capacity.ColCount - 1 do
  begin
    if not (CheckString(Capacity.Cells[i, 0])) or not (CheckString(Capacity.Cells[i,1])) or not (CheckString(Capacity.Cells[i,2])) then
    begin
      ShowMessage('Таблица "Стандартный ряд емкостей" заполнена неверно или не заполнена');
      exit;
    end;
  end;

  for i := 1 to Apparatus.ColCount - 1 do
  begin
  if not (CheckString(Apparatus.Cells[i, 0])) or not (CheckString(Apparatus.Cells[i,1])) then
    begin
      ShowMessage('Таблица "Стандартный ряд аппаратов" заполнена неверно или не заполнена');
      exit;
    end;
  end;
  PageControl1.SelectNextPage(true);
end;

procedure TForm1.CheckBoxClickCool(Sender: TObject);
var i:integer;
begin
    i := getCheckBoxNumber((Sender as TCheckBox), rowListCool);
    if rowListCool[i].check.Checked then
    begin
      rowListCool[i].startTemp.Enabled := true;
      rowListCool[i].endTemp.Enabled := true;
      rowListCool[i].agentTemp.Enabled := true;
      rowListCool[i].selfHeat.Enabled := false;
    end else
    begin
      rowListCool[i].startTemp.Enabled := false;
      rowListCool[i].endTemp.Enabled := false;
      rowListCool[i].agentTemp.Enabled := false;
      rowListCool[i].selfHeat.Enabled := true;
    end;
end;

procedure TForm1.CheckBoxClickHeat(Sender: TObject);
var i:integer;
begin
    i := getCheckBoxNumber((Sender as TCheckBox), rowListHeat);
    if rowListHeat[i].check.Checked then
    begin
      rowListHeat[i].startTemp.Enabled := true;
      rowListHeat[i].endTemp.Enabled := true;
      rowListHeat[i].agentTemp.Enabled := true;
      rowListHeat[i].selfHeat.Enabled := false;
    end else
    begin
      rowListHeat[i].startTemp.Enabled := false;
      rowListHeat[i].endTemp.Enabled := false;
      rowListHeat[i].agentTemp.Enabled := false;
      rowListHeat[i].selfHeat.Enabled := true;
    end;
end;

function GetRtfText(aRe : TRichEdit) : String;
var
  Ss : TStringStream;
begin
  Ss := TStringStream.Create('');
  aRe.Lines.SaveToStream(Ss);
  Result := Ss.DataString;
  FreeAndNil(Ss);
end;

function getRichGrid(SG: TStringGrid;aRe:TRichEdit):TStringStream;
const
  Cr: String = Char(13) + Char(10);
  CellWidth: Integer = 1900;
  CellIndent: Integer = 55;
Var i:integer;
  ColNum  : Integer;
  RowNum  : Integer;
  StrRtf: String;
  S, STable, SDoc : String;
  P1, LenS, LenT : Integer;
begin
  StrRtf := '{\rtf1\ansi\ansicpg1251' + Cr;
  for RowNum := 0 to SG.RowCount - 1 do begin
    StrRtf := StrRtf + '\trowd\trgaph' + IntToStr(CellIndent) + CR;
    i := 0;
    for ColNum := 0 to SG.ColCount - 1 do begin
      Inc(i);
      StrRtf :=
        StrRtf
        + '\clbrdrt\brdrs\clbrdrl\brdrs\clbrdrb\brdrs\clbrdrr\brdrs\cellx'
        + IntToStr(i * CellWidth) + Cr;
    end;
    StrRtf := StrRtf + '\pard\intbl' + Cr;
    for ColNum := 0 to SG.ColCount - 1 do begin
      if (SG.Cells[ColNum, RowNum] = '') and (ColNum <> 0) and (RowNum <> 0) then
        StrRtf := StrRtf + ' -' + '\cell' + Cr
      else
        StrRtf := StrRtf + SG.Cells[ColNum, RowNum] + '\cell' + Cr;
    end;
    StrRtf := StrRtf + '\row' + Cr;
  end;
  StrRtf := StrRtf + '}';

  S := '#table#';
  LenS := Length(S);
  if LenS = 0 then Exit;

  SDoc := GetRtfText(aRe);
  LenT := Length(STable);
  P1 := PosEx(S, SDoc, 1);
  STable := #13#10 + StrRtf;
  while P1 > 0 do begin
    Delete(SDoc, P1, LenS);
    Insert(STable, SDoc, P1);
    P1 := PosEx(S, SDoc, P1 + LenT);
  end;


  Result := TStringStream.Create(SDoc);

end;

function getRichGridFMatrix(Matrix: Matrix;aRe:TRichEdit;NameofCol:String;
                              NameofRow:String;NullName:String):TStringStream;
const
  Cr: String = Char(13) + Char(10);
  CellWidth: Integer = 1200;
  CellIndent: Integer = 50;
Var i:integer;
  ColNum  : Integer;
  RowNum  : Integer;
  StrRtf: String;
  S, STable, SDoc : String;
  P1, LenS, LenT : Integer;
  StrMat:StrMatrix;
begin
  SetLength(StrMat, Length(Matrix[0]) + 1, Length(Matrix) + 1);

  for ColNum := 1 to Length(Matrix) do
    StrMat[0,Colnum] := NameofCol+' '+IntTostr(Colnum);

  for RowNum := 1 to Length(Matrix[0]) do
    StrMat[RowNum,0] := NameofRow+' '+IntTostr(RowNum);

   for ColNum := 1 to Length(Matrix) do begin
    for RowNum := 1 to Length(Matrix[0]) do begin
      if Matrix[ColNum - 1,RowNum - 1] = 0 then begin
        StrMat[RowNum,ColNum] := NullName;
      end else
        StrMat[RowNum,ColNum] := FloatToStr(Matrix[ColNum-1,RowNum-1]);
    end;
   end;


  StrRtf := '{\rtf1\ansi\ansicpg1251' + Cr;
  for ColNum := 0 to length(StrMat) - 1 do begin
    StrRtf := StrRtf + '\trowd\trgaph' + IntToStr(CellIndent) + CR;
    i := 0;
    for RowNum := 0 to length(StrMat[0]) - 1 do begin
      Inc(i);
      StrRtf :=
        StrRtf
        + '\clbrdrt\brdrs\clbrdrl\brdrs\clbrdrb\brdrs\clbrdrr\brdrs\cellx'
        + IntToStr(i * CellWidth) + Cr;
    end;
    StrRtf := StrRtf + '\pard\intbl' + Cr;
    for RowNum := 0 to length(StrMat[0]) - 1 do begin
      StrRtf := StrRtf + StrMat[ColNum,RowNum] + '\cell' + Cr;
    end;
    StrRtf := StrRtf + '\row' + Cr;
  end;
  StrRtf := StrRtf + '}';

  S := '#table#';
  LenS := Length(S);
  if LenS = 0 then Exit;

  SDoc := GetRtfText(aRe);
  LenT := Length(STable);
  P1 := PosEx(S, SDoc, 1);
  STable := #13#10 + StrRtf;
  while P1 > 0 do begin
    Delete(SDoc, P1, LenS);
    Insert(STable, SDoc, P1);
    P1 := PosEx(S, SDoc, P1 + LenT);
  end;
  Result := TStringStream.Create(SDoc);
end;


procedure AddColoredLine(ARichEdit: TRichEdit; AText: string; AColor: TColor);
 begin
   with ARichEdit do
   begin
     SelStart := Length(Text);
     SelAttributes.Color := AColor;
     SelAttributes.Size := 10;
     SelAttributes.Name := 'MS Sans Serif';
     Lines.Add(AText);
   end;
 end;

procedure TForm1.FormCreate(Sender: TObject);
var i:integer;
begin
  SpinEdit3.Value := 1;
  setLength(rowListHeat, SpinEdit3.value);
  setLength(rowListCool, SpinEdit3.value);
  for i := 0 to SpinEdit3.Value - 1 do
 begin

   rowListHeat[i].check := createCheckBox(rowListHeat[i].check, i, ScrollBox1, Self);
   rowListHeat[i].check.OnClick := Self.CheckBoxClickHeat;
   rowListHeat[i].startTemp := setEditOfHeatRow(rowListHeat[i].startTemp, i, 1, ScrollBox1, Self);
   rowListHeat[i].endTemp := setEditOfHeatRow(rowListHeat[i].endTemp, i, 2, ScrollBox1, Self);
   rowListHeat[i].agentTemp := setEditOfHeatRow(rowListHeat[i].agentTemp, i, 3, ScrollBox1, Self);
   rowListHeat[i].selfHeat := setEditOfHeatRow(rowListHeat[i].selfHeat, i, 4, ScrollBox1, Self);

   rowListCool[i].check := createCheckBox(rowListCool[i].check, i, ScrollBox2, Self);
   rowListCool[i].check.OnClick := Self.CheckBoxClickCool;
   rowListCool[i].startTemp := setEditOfHeatRow(rowListCool[i].startTemp, i, 1, ScrollBox2, Self);
   rowListCool[i].endTemp := setEditOfHeatRow(rowListCool[i].endTemp, i, 2, ScrollBox2, Self);
   rowListCool[i].agentTemp := setEditOfHeatRow(rowListCool[i].agentTemp, i, 3, ScrollBox2, Self);
   rowListCool[i].selfHeat := setEditOfHeatRow(rowListCool[i].selfHeat, i, 4, ScrollBox2, Self);
 end;
  Form1.SpinEdit3Change(SpinEdit3);
  StringGrid1.Cells[1,0] := 'Размер партии';
  StringGrid2.Cells[1,0] := 'Плотность';
  StringGrid3.Cells[1,0] := 'Плотность';
  StringGrid4.Cells[1,0] := 'Вх. поток';
  StringGrid4.Cells[2,0] := 'Доб. поток';
  StringGrid4.Cells[3,0] := 'Вых. поток';
  StringGrid5.Cells[1,0] := 'Доб/Вых';
  StringGrid5.Cells[2,0] := 'Вх/Вых';
  StringGrid6.Cells[1,0] := 'Выгрузка';
  StringGrid6.Cells[2,0] := 'Загрузки вх. пот.';
  StringGrid6.Cells[3,0] := 'Загрузки доб. пот.';
  //StringGrid7.Cells[1,0] := 'Плотность';
  StringGrid11.Cells[1,0] := 'Коэф. теплопер.';
  StringGrid12.Cells[1,0] := 'Длит. ХР';
  StringGrid13.Cells[1,0] := 'РМ';
  StringGrid13.Cells[2,0] := 'Аппарата';
  StringGrid14.Cells[1,0] := 'Для аппаратов';
  StringGrid14.Cells[2,0] := 'Для мерников';

  StringGrid1.Cells[1,1] := '40;130';
  StringGrid2.Cells[1,1] := '800';
  StringGrid3.Cells[1,1] := '1250';
  StringGrid4.Cells[1,1] := '0,6';
  StringGrid4.Cells[2,1] := '0,7';
  StringGrid4.Cells[3,1] := '0,8';
  StringGrid5.Cells[1,1] := '0,2';
  StringGrid5.Cells[2,1] := '0,8';
  StringGrid6.Cells[1,1] := '0,02';
  StringGrid6.Cells[2,1] := '0,02';
  StringGrid6.Cells[3,1] := '0,02';
  //StringGrid7.Cells[1,1] := '999';
  StringGrid11.Cells[1,1] := '500';
  StringGrid12.Cells[1,1] := '2';
  StringGrid13.Cells[1,1] := '2250';
  StringGrid13.Cells[2,1] := '485';
  StringGrid14.Cells[1,1] := '0,1;0,9';
  StringGrid14.Cells[2,1] := '0,1;0,9';

  Apparatus.Cells[0,0] := 'V, м^3';
      Apparatus.Cells[1,0] := '0,01';
      Apparatus.Cells[2,0] := '0,025';
      Apparatus.Cells[3,0] := '0,04';
      Apparatus.Cells[4,0] := '0,063';
      Apparatus.Cells[5,0] := '0,1';
      Apparatus.Cells[6,0] := '0,16';
      Apparatus.Cells[7,0] := '0,4';
      Apparatus.Cells[8,0] := '0,63';
      Apparatus.Cells[9,0] := '1,0';
    Apparatus.Cells[0,1] := 'm, кг';
      Apparatus.Cells[1,1] := '300';
      Apparatus.Cells[2,1] := '320';
      Apparatus.Cells[3,1] := '360';
      Apparatus.Cells[4,1] := '370';
      Apparatus.Cells[5,1] := '420';
      Apparatus.Cells[6,1] := '480';
      Apparatus.Cells[7,1] := '500';
      Apparatus.Cells[8,1] := '600';
      Apparatus.Cells[9,1] := '650';

    Capacity.Cells[0,0] := 'D, м';
      Capacity.Cells[1,0] := '0,2';
      Capacity.Cells[2,0] := '0,3';
      Capacity.Cells[3,0] := '0,5';
      Capacity.Cells[4,0] := '0,6';
      Capacity.Cells[5,0] := '0,7';
      Capacity.Cells[6,0] := '0,8';
      Capacity.Cells[7,0] := '1,0';
      Capacity.Cells[8,0] := '1,2';
    Capacity.Cells[0,1] := 'H, м';
      Capacity.Cells[1,1] := '0,3';
      Capacity.Cells[2,1] := '0,5';
      Capacity.Cells[3,1] := '0,8';
      Capacity.Cells[4,1] := '0,8';
      Capacity.Cells[5,1] := '0,9';
      Capacity.Cells[6,1] := '1,0';
      Capacity.Cells[7,1] := '1,5';
      Capacity.Cells[8,1] := '1,8';
    Capacity.Cells[0,2] := 'V, м^3';
      Capacity.Cells[1,2] := '0,0094';
      Capacity.Cells[2,2] := '0,0353';
      Capacity.Cells[3,2] := '0,157';
      Capacity.Cells[4,2] := '0,226';
      Capacity.Cells[5,2] := '0,346';
      Capacity.Cells[6,2] := '0,502';
      Capacity.Cells[7,2] := '1,177';
      Capacity.Cells[8,2] := '2,034';

end;

procedure TForm1.FormResize(Sender: TObject);
begin
  Button1.Top := Form1.ClientHeight - 55;
  Button2.Top := Form1.ClientHeight - 55;
  Button6.Top := Form1.ClientHeight - 55;
  Button7.Top := Form1.ClientHeight - 55;
  Расчитать.Top := Form1.ClientHeight - 55;
  RichEdit1.Height := Form1.ClientHeight - 60;
  if Form1.ClientWidth > 300 then begin
    Расчитать.Left := Form1.ClientWidth - 90;
    Button1.Left := Form1.ClientWidth - 190;
    Button2.Left := Form1.ClientWidth - 90;
    Button6.Left := Form1.ClientWidth - 90;
    Button7.Left := Form1.ClientWidth - 90;
  end;
  if (Form1.ClientWidth < 430) then Form1.ClientWidth := 430;
  if (Form1.ClientHeight < 420) then Form1.ClientHeight := 420;

end;

procedure TForm1.N2Click(Sender: TObject);
begin
  ShowMessage('"Duration" '+#13#10+'Autor: Agrass'+#13#10+'Version: 3.1 beta');
end;

procedure TForm1.N3Click(Sender: TObject);
var IniFile: TIniFile;
    i,j: Integer;
begin
  if SaveDialog1.Execute then
  begin
    IniFile := TIniFile.Create(SaveDialog1.FileName+'.ini');
    try
      IniFile.WriteInteger('Step1','NumbOfProd',SpinEdit3.Value);

      for i := 1 to StringGrid1.ColCount - 1 do
        for j := 1 to StringGrid1.RowCount - 1 do
          IniFile.WriteString('BatchSize',inttostr(i)+'_'+inttostr(j),StringGrid1.Cells[i,j]);

      for i := 1 to StringGrid2.ColCount - 1 do
        for j := 1 to StringGrid2.RowCount - 1 do
          IniFile.WriteString('DenInputStr',inttostr(i)+'_'+inttostr(j),StringGrid2.Cells[i,j]);

      for i := 1 to StringGrid3.ColCount - 1 do
        for j := 1 to StringGrid3.RowCount - 1 do
          IniFile.WriteString('DenAddStr',inttostr(i)+'_'+inttostr(j),StringGrid3.Cells[i,j]);

      for i := 1 to StringGrid4.ColCount - 1 do
        for j := 1 to StringGrid4.RowCount - 1 do
          IniFile.WriteString('CoefRash',inttostr(i)+'_'+inttostr(j),StringGrid4.Cells[i,j]);

      for i := 1 to StringGrid5.ColCount - 1 do
        for j := 1 to StringGrid5.RowCount - 1 do
          IniFile.WriteString('RashCoef',inttostr(i)+'_'+inttostr(j),StringGrid5.Cells[i,j]);

      for i := 1 to StringGrid6.ColCount - 1 do
        for j := 1 to StringGrid6.RowCount - 1 do
          IniFile.WriteString('ShtDiam',inttostr(i)+'_'+inttostr(j),StringGrid6.Cells[i,j]);

      for i := 1 to StringGrid11.ColCount - 1 do
        for j := 1 to StringGrid11.RowCount - 1 do
          IniFile.WriteString('CoefTeplPer',inttostr(i)+'_'+inttostr(j),StringGrid11.Cells[i,j]);

      for i := 1 to StringGrid12.ColCount - 1 do
        for j := 1 to StringGrid12.RowCount - 1 do
          IniFile.WriteString('ChemDur',inttostr(i)+'_'+inttostr(j),StringGrid12.Cells[i,j]);

      for i := 1 to StringGrid13.ColCount - 1 do
        for j := 1 to StringGrid13.RowCount - 1 do
          IniFile.WriteString('heatCapacity',inttostr(i)+'_'+inttostr(j),StringGrid13.Cells[i,j]);

      for i := 1 to StringGrid14.ColCount - 1 do
        for j := 1 to StringGrid14.RowCount - 1 do
          IniFile.WriteString('FillFactor',inttostr(i)+'_'+inttostr(j),StringGrid14.Cells[i,j]);

      IniFile.WriteInteger('Step3','NumbOfApp',SpinEdit1.Value);
      IniFile.WriteInteger('Step3','NumbOfcapacity',SpinEdit2.Value);

      for i := 1 to Capacity.ColCount - 1 do
        for j := 0 to Capacity.RowCount - 1 do
          IniFile.WriteString('Capacity',inttostr(i)+'_'+inttostr(j),Capacity.Cells[i,j]);

      for i := 1 to Apparatus.ColCount - 1 do
        for j := 0 to Apparatus.RowCount - 1 do
          IniFile.WriteString('App',inttostr(i)+'_'+inttostr(j),Apparatus.Cells[i,j]);
    finally
      IniFile.Free;
    end;
  end;
end;

procedure TForm1.N4Click(Sender: TObject);
var IniFile: TIniFile;
    i,j: Integer;
begin
  if OpenDialog1.Execute then
  begin
    try
      IniFile := TIniFile.Create(OpenDialog1.FileName);
      SpinEdit3.Value := IniFile.ReadInteger('Step1','NumbOfProd',SpinEdit3.Value);
      SpinEdit1.Value := IniFile.ReadInteger('Step3','NumbOfApp',SpinEdit1.Value);
      SpinEdit2.Value := IniFile.ReadInteger('Step3','NumbOfcapacity',SpinEdit2.Value);

      Form1.SpinEdit1Change(SpinEdit1);
      Form1.SpinEdit2Change(SpinEdit2);
      Form1.SpinEdit3Change(SpinEdit3);

      StringGrid1.RowCount := SpinEdit3.Value + 1;
      StringGrid2.RowCount := SpinEdit3.Value + 1;
      StringGrid4.RowCount := SpinEdit3.Value + 1;
      StringGrid5.RowCount := SpinEdit3.Value + 1;
      StringGrid11.RowCount := SpinEdit3.Value + 1;
      StringGrid12.RowCount := SpinEdit3.Value + 1;
      StringGrid13.RowCount := SpinEdit3.Value + 1;

      for i := 1 to StringGrid6.ColCount - 1 do
        for j := 1 to StringGrid6.RowCount - 1 do
          StringGrid6.Cells[i,j] := IniFile.ReadString('ShtDiam',inttostr(i)+'_'+inttostr(j), StringGrid6.Cells[i,j]);

      for i := 1 to StringGrid1.ColCount - 1 do
        for j := 1 to StringGrid1.RowCount - 1 do
         StringGrid1.Cells[i,j] := IniFile.ReadString('BatchSize',inttostr(i)+'_'+inttostr(j),StringGrid1.Cells[i,j]);

      for i := 1 to StringGrid2.ColCount - 1 do
        for j := 1 to StringGrid2.RowCount - 1 do
          StringGrid2.Cells[i,j] :=  IniFile.ReadString('DenInputStr',inttostr(i)+'_'+inttostr(j),StringGrid2.Cells[i,j]);

      for i := 1 to StringGrid3.ColCount - 1 do
        for j := 1 to StringGrid3.RowCount - 1 do
          StringGrid3.Cells[i,j] := IniFile.ReadString('DenAddStr',inttostr(i)+'_'+inttostr(j),StringGrid3.Cells[i,j]);

      for i := 1 to StringGrid4.ColCount - 1 do
        for j := 1 to StringGrid4.RowCount - 1 do
          StringGrid4.Cells[i,j] := IniFile.ReadString('CoefRash',inttostr(i)+'_'+inttostr(j),StringGrid4.Cells[i,j]);

      for i := 1 to StringGrid5.ColCount - 1 do
        for j := 1 to StringGrid5.RowCount - 1 do
          StringGrid5.Cells[i,j] := IniFile.ReadString('RashCoef',inttostr(i)+'_'+inttostr(j),StringGrid5.Cells[i,j]);


      for i := 1 to StringGrid11.ColCount - 1 do
        for j := 1 to StringGrid11.RowCount - 1 do
          StringGrid11.Cells[i,j] := IniFile.ReadString('CoefTeplPer',inttostr(i)+'_'+inttostr(j),StringGrid11.Cells[i,j]);

      for i := 1 to StringGrid12.ColCount - 1 do
        for j := 1 to StringGrid12.RowCount - 1 do
          StringGrid12.Cells[i,j] := IniFile.ReadString('ChemDur',inttostr(i)+'_'+inttostr(j),StringGrid12.Cells[i,j]);

      for i := 1 to StringGrid13.ColCount - 1 do
        for j := 1 to StringGrid13.RowCount - 1 do
          StringGrid13.Cells[i,j] := IniFile.ReadString('heatCapacity',inttostr(i)+'_'+inttostr(j),StringGrid13.Cells[i,j]);

      for i := 1 to StringGrid14.ColCount - 1 do
        for j := 1 to StringGrid14.RowCount - 1 do
          StringGrid14.Cells[i,j] := IniFile.ReadString('FillFactor',inttostr(i)+'_'+inttostr(j),StringGrid14.Cells[i,j]);

     for i := 1 to Capacity.ColCount - 1 do
        for j := 0 to Capacity.RowCount - 1 do
          Capacity.Cells[i,j] := IniFile.ReadString('Capacity',inttostr(i)+'_'+inttostr(j),Capacity.Cells[i,j]);

      for i := 1 to Apparatus.ColCount - 1 do
        for j := 0 to Apparatus.RowCount - 1 do
          Apparatus.Cells[i,j] := IniFile.ReadString('App',inttostr(i)+'_'+inttostr(j),Apparatus.Cells[i,j]);

    finally
      IniFile.Free;
    end;
  end;
end;

procedure TForm1.N6Click(Sender: TObject);
begin
  Form1.Close;
end;

procedure TForm1.SpinEdit1Change(Sender: TObject);
begin
  Apparatus.ColCount := SpinEdit1.Value + 1;
end;

procedure TForm1.SpinEdit2Change(Sender: TObject);
begin
   Capacity.ColCount := SpinEdit2.Value + 1;
end;

procedure TForm1.SpinEdit3Change(Sender: TObject);
var
  i: Integer;
begin

  StringGrid1.RowCount := SpinEdit3.Value + 1;
  StringGrid2.RowCount := SpinEdit3.Value + 1;
  StringGrid3.RowCount := SpinEdit3.Value + 1;
  StringGrid4.RowCount := SpinEdit3.Value + 1;
  StringGrid5.RowCount := SpinEdit3.Value + 1;
  StringGrid6.RowCount := SpinEdit3.Value + 1;
  StringGrid11.RowCount := SpinEdit3.Value + 1;
  StringGrid12.RowCount := SpinEdit3.Value + 1;
  StringGrid13.RowCount := SpinEdit3.Value + 1;
  StringGrid14.RowCount := SpinEdit3.Value + 1;
  for i := 1 to SpinEdit3.Value do
  begin
    StringGrid1.Cells[0,i] := 'Продукт '+IntToStr(i);
    StringGrid2.Cells[0,i] := 'Продукт '+IntToStr(i);
    StringGrid3.Cells[0,i] := 'Продукт '+IntToStr(i);
    StringGrid4.Cells[0,i] := 'Продукт '+IntToStr(i);
    StringGrid5.Cells[0,i] := 'Продукт '+IntToStr(i);
    StringGrid6.Cells[0,i] := 'Продукт '+IntToStr(i);
    StringGrid11.Cells[0,i] := 'Продукт '+IntToStr(i);
    StringGrid12.Cells[0,i] := 'Продукт '+IntToStr(i);
    StringGrid13.Cells[0,i] := 'Продукт '+IntToStr(i);
    StringGrid14.Cells[0,i] := 'Продукт '+IntToStr(i);
  end;

  if SpinEdit3.Value < length(rowListHeat) then
   begin
      FreeAndNil(rowListHeat[SpinEdit3.Value].check);
      FreeAndNil(rowListHeat[SpinEdit3.Value].startTemp);
      FreeAndNil(rowListHeat[SpinEdit3.Value].endTemp);
      FreeAndNil(rowListHeat[SpinEdit3.Value].agentTemp);
      FreeAndNil(rowListHeat[SpinEdit3.Value].selfHeat);

      FreeAndNil(rowListCool[SpinEdit3.Value].check);
      FreeAndNil(rowListCool[SpinEdit3.Value].startTemp);
      FreeAndNil(rowListCool[SpinEdit3.Value].endTemp);
      FreeAndNil(rowListCool[SpinEdit3.Value].agentTemp);
      FreeAndNil(rowListCool[SpinEdit3.Value].selfHeat);

      setLength(rowListHeat, SpinEdit3.value);
      setLength(rowListCool, SpinEdit3.value);
   end;

   if SpinEdit3.Value > length(rowListHeat) then
   begin
    setLength(rowListHeat, SpinEdit3.value);
    setLength(rowListCool, SpinEdit3.value);
    i := SpinEdit3.value - 1;
    rowListHeat[i].check := createCheckBox(rowListHeat[i].check, i, ScrollBox1, Self);
    rowListHeat[i].check.OnClick := Self.CheckBoxClickHeat;
    rowListHeat[i].startTemp := setEditOfHeatRow(rowListHeat[i].startTemp, i, 1, ScrollBox1, Self);
    rowListHeat[i].endTemp := setEditOfHeatRow(rowListHeat[i].endTemp, i, 2, ScrollBox1, Self);
    rowListHeat[i].agentTemp := setEditOfHeatRow(rowListHeat[i].agentTemp, i, 3, ScrollBox1, Self);
    rowListHeat[i].selfHeat := setEditOfHeatRow(rowListHeat[i].selfHeat, i, 4, ScrollBox1, Self);

    rowListCool[i].check := createCheckBox(rowListCool[i].check, i, ScrollBox2, Self);
    rowListCool[i].check.OnClick := Self.CheckBoxClickCool;
    rowListCool[i].startTemp := setEditOfHeatRow(rowListCool[i].startTemp, i, 1, ScrollBox2, Self);
    rowListCool[i].endTemp := setEditOfHeatRow(rowListCool[i].endTemp, i, 2, ScrollBox2, Self);
    rowListCool[i].agentTemp := setEditOfHeatRow(rowListCool[i].agentTemp, i, 3, ScrollBox2, Self);
    rowListCool[i].selfHeat := setEditOfHeatRow(rowListCool[i].selfHeat, i, 4, ScrollBox2, Self);
   end;

// setLength(rowListHeat, SpinEdit3.value);
// setLength(rowListCool, SpinEdit3.value);
// for i := 0 to SpinEdit3.Value - 1 do
// begin
//
//   rowListHeat[i].check := createCheckBox(rowListHeat[i].check, i, ScrollBox1, Self);
//   rowListHeat[i].check.OnClick := Self.CheckBoxClickHeat;
//   rowListHeat[i].startTemp := setEditOfHeatRow(rowListHeat[i].startTemp, i, 1, ScrollBox1, Self);
//   rowListHeat[i].endTemp := setEditOfHeatRow(rowListHeat[i].endTemp, i, 2, ScrollBox1, Self);
//   rowListHeat[i].agentTemp := setEditOfHeatRow(rowListHeat[i].agentTemp, i, 3, ScrollBox1, Self);
//   rowListHeat[i].selfHeat := setEditOfHeatRow(rowListHeat[i].selfHeat, i, 4, ScrollBox1, Self);
//
//   rowListCool[i].check := createCheckBox(rowListCool[i].check, i, ScrollBox2, Self);
//   rowListCool[i].check.OnClick := Self.CheckBoxClickCool;
//   rowListCool[i].startTemp := setEditOfHeatRow(rowListCool[i].startTemp, i, 1, ScrollBox2, Self);
//   rowListCool[i].endTemp := setEditOfHeatRow(rowListCool[i].endTemp, i, 2, ScrollBox2, Self);
//   rowListCool[i].agentTemp := setEditOfHeatRow(rowListCool[i].agentTemp, i, 3, ScrollBox2, Self);
//   rowListCool[i].selfHeat := setEditOfHeatRow(rowListCool[i].selfHeat, i, 4, ScrollBox2, Self);
// end;


end;

function GetDensityRaw(DensInpStr,DensAddStr,ExpFactInpStr,ExpFactAddStr: real): double;
begin
  Result:= RoundTo(1/((ExpFactInpStr/DensInpStr)+(ExpFactAddStr/DensAddStr)),-3);
end;

function GetStepMapIndex(ExpFactInpStr:real;ExpFactAddStr:real; DensRaw:real;
           DensAddStr:real):real;
begin
  result := RoundTo((ExpFactInpStr/DensRaw) + (ExpFactAddStr/DensAddStr),-5);
end;

function getReallFillFactor(StepMapInd,MaxBatchSize,DispMachine:extended):real;
begin
  result:= RoundTo((StepMapInd*MaxBatchSize)/DispMachine,-3);
end;

function getAppSize(product_: product;
                    pMachine: array of Machine;
                    minFillFactor: extended): product;
var i:integer;
begin
  for i := 0 to length(pMachine) do
      begin
        if (pMachine[i].V >= product_.DemUnit.left)
          and (product_.DemUnit.right >= pMachine[i].V) then
          begin
            product_.pMachine.V := pMachine[i].V;
            product_.pMachine.m := pMachine[i].m;
            product_.pRealFillFactor.Real := getReallFillFactor(
                                            product_.StepMapIndex,
                                            product_.pBatchSize,
                                            product_.pMachine.V);
            if (product_.pRealFillFactor.Real < minFillFactor) then
                begin
                  result := product_;
                  break;
                end;
          end;
      end;
end;

function max(putArray:array of extended):real;
var i: Integer;
    max: real;
begin
  max := putArray[0];
  for i := 0 to length(putArray) - 1 do
    begin
      if putArray[i] >= max  then
        max := putArray[i];
    end;
  result := max;
end;

function getMaxSizeOfMachine(products_: array of product): extended;
var i: Integer;
    maxSize: extended;
begin
   maxSize := products_[0].pMachine.V;
  for i := 0 to length(products_) - 1 do
    begin
      if products_[i].pMachine.V <= maxSize  then
        maxSize := products_[i].pMachine.V;
    end;
  result := maxSize;
end;

function getMaxSizeCapacityForAddStr(products_: array of product): extended;
var i: Integer;
    maxSize: extended;
begin
   maxSize := products_[0].pCapacityForAddStr.V;
  for i := 0 to length(products_) - 1 do
    begin
      if products_[i].pCapacityForAddStr.V <= maxSize  then
        maxSize := products_[i].pCapacityForAddStr.V;
    end;
  result := maxSize;
end;

function getMaxSizepCapacityForRawStr(products_: array of product): extended;
var i: Integer;
    maxSize: extended;
begin
   maxSize := products_[0].pCapacityForRawStr.V;
  for i := 0 to length(products_) - 1 do
    begin
      if products_[i].pCapacityForRawStr.V <= maxSize  then
        maxSize := products_[i].pCapacityForRawStr.V;
    end;
  result := maxSize;
end;

function getCapacitySize(product_:product;
                        VolumeAddStr:extended;
                        capacityFillFactor: FillFactor;
                        pCapacity: array of Capacity
                        ): Capacity;
var i:integer;
begin
  for i := 0 to length(pCapacity) - 1  do
      begin
        if pCapacity[i].V >= VolumeAddStr then
          begin
            result:= pCapacity[i];
            break;
          end;

      end;
end;

function getMaxBatchSize(Volume:extended;
                          Dens:extended;
                          ExpFact: extended;
                          fillFactor: FillFactor): extended;
begin
  Result := RoundTo(Volume*Dens*fillFactor.upper/ExpFact,-3);
end;

function GetDuration(DApp:real;InitHeight:real;DFit:real;ExpFactor:Real):integer;
var F,fsht:extended;
begin
  F := 3.14*sqr(DApp)/4;
  fsht := 3.14*sqr(DFit)/4;
  result:= Round(2*F*sqrt(InitHeight)/(fsht*ExpFactor*sqrt(2*9.8)));
end;


function GetMotPowHeat(TempBeg, TempEnd, Agent:real):real;
begin
  result := ((Agent - TempBeg) - (Agent - TempEnd))/(Ln((Agent - TempBeg)/(Agent - TempEnd)));
end;

function GetMotPowCool(TempBeg, TempEnd, Agent:real):real;
begin
  result := ((TempBeg - Agent) - (TempEnd - Agent))/(Ln((TempBeg - Agent)/(TempEnd - Agent)));
end;

function getDurationHeat(BatchSize, HeatCapacityRm, HeatCapacityMach, MassMach,
                          TempHeatEnd, TempHeatBeg, SurfaceTrans, MPHeat,
                          K :real):integer;
begin
  result := Round((BatchSize*HeatCapacityRm + HeatCapacityMach*MassMach)*
                  (TempHeatEnd - TempHeatBeg)/(SurfaceTrans*MPHeat*K));
end;

function getMaxLimit(products: array of product): extended;
var i:integer;
    max: extended;
begin
  max := 0;
  for i := 0 to length(products) - 1 do
    begin
      if max < products[i].DemUnit.left then
        max := products[i].DemUnit.left;
    end;
    result := max;
end;

function getMinLimit(products: array of product): extended;
var i:integer;
    min: extended;
begin
  min := products[0].DemUnit.right;
  for i := 0 to length(products) - 1 do
    begin
      if min > products[i].DemUnit.right then
        min := products[i].DemUnit.right;
    end;
    result := min;
end;

procedure TForm1.РасчитатьClick(Sender: TObject);
var i: integer;
StrList: TStringList;
InitHeight:real;
begin
  numbOfProduct := SpinEdit3.Value;
  Setlength(productsBatchSize, numbOfProduct);
  Setlength(DensInpStr, numbOfProduct);
  Setlength(DensAddStr, numbOfProduct);
  Setlength(DensRaw, numbOfProduct);
  Setlength(productFlowFact, numbOfProduct);
  Setlength(productExpFact, numbOfProduct);
  Setlength(pDSht, numbOfProduct);
  Setlength(productHeatCapacity, numbOfProduct);
  Setlength(heatTransfer, numbOfProduct);
  Setlength(durationChemicalReact, numbOfProduct);
  Setlength(machFillFactor, numbOfProduct);
  Setlength(capacityFillFactor, numbOfProduct);
  Setlength(pMachine, SpinEdit1.Value);
  Setlength(pCapacity, SpinEdit2.Value);
  Setlength(products, numbOfProduct);
  Setlength(productHeat, numbOfProduct);
  Setlength(productCool, numbOfProduct);

  StrList := TStringList.Create;
//---------------------------------------------------------------------------->
// ------------------------ Checks begin ------------------------------------->
//---------------------------------------------------------------------------->
  for i := 0 to numbOfProduct - 1 do
  begin
    if not CheckString(StringGrid1.Cells[1, i + 1]) then
    begin
      ShowMessage('Таблица "Размеры партиий продуктов" заполнена неверно или неполностью');
      exit;
    end;
    products[i].pBatchSize := StrToFloat(StringGrid1.Cells[1,i + 1]);

    if not CheckString(StringGrid2.Cells[1,i + 1]) then
    begin
      ShowMessage('Таблица "Плотность входных потоков" заполнена неверно или неполностью');
      exit;
    end;
    DensInpStr[i] := StrToFloat(StringGrid2.Cells[1,i + 1]);

    if not CheckString(StringGrid3.Cells[1,i + 1]) then
    begin
      ShowMessage('Таблица "Плотность доп. потоков" заполнена неверно или неполностью');
      exit;
    end;
    DensAddStr[i] := StrToFloat(StringGrid3.Cells[1,i + 1]);


//    DensRaw[i] := StrToFloat(StringGrid7.Cells[1,i + 1]);

    if not CheckString(StringGrid4.Cells[1,i + 1]) or not CheckString(StringGrid4.Cells[2,i + 1])
        or not CheckString(StringGrid4.Cells[3,i + 1]) then
    begin
      ShowMessage('Таблица "Коэффициенты расхода" заполнена неверно или неполностью');
      exit;
    end;
    productFlowFact[i].InpStr := StrToFloat(StringGrid4.Cells[1,i + 1]);
    productFlowFact[i].AddStr := StrToFloat(StringGrid4.Cells[2,i + 1]);
    productFlowFact[i].OutStr := StrToFloat(StringGrid4.Cells[3,i + 1]);

    if not CheckString(StringGrid5.Cells[2,i + 1]) or not CheckString(StringGrid5.Cells[1,i + 1]) then
    begin
      ShowMessage('Таблица "расходные коэффициенты" заполнена неверно или неполностью');
      exit;
    end;
    productExpFact[i].InpStr := StrToFloat(StringGrid5.Cells[2,i + 1]);
    productExpFact[i].AddStr := StrToFloat(StringGrid5.Cells[1,i + 1]);


    if not CheckString(StringGrid6.Cells[3,i + 1]) or not CheckString(StringGrid6.Cells[1,i + 1])
        or not CheckString(StringGrid6.Cells[2,i + 1]) then
    begin
      ShowMessage('Таблица "Диаметры штуцеров" заполнена неверно или неполностью');
      exit;
    end;
    pDSht[i].AddStr := StrToFloat(StringGrid6.Cells[3,i + 1]);
    pDSht[i].Unload := StrToFloat(StringGrid6.Cells[1,i + 1]);
    pDSht[i].Raw := StrToFloat(StringGrid6.Cells[2,i + 1]);

    if rowListHeat[i].check.Checked then
      begin
        if not CheckString(rowListHeat[i].startTemp.Text) then
          begin
            ShowMessage('Поле "Начальная температура нагревания" заполнено неверно или не заполнено');
            exit;
          end;
        productHeat[i].startTemp := StrToFloat(rowListHeat[i].startTemp.Text);

        if not CheckString(rowListHeat[i].endTemp.Text) then
          begin
            ShowMessage('Поле "Конечная температура нагревания" заполнено неверно или не заполнено');
            exit;
          end;
        productHeat[i].endTemp := StrToFloat(rowListHeat[i].endTemp.Text);

        if not CheckString(rowListHeat[i].agentTemp.Text) then
          begin
            ShowMessage('Поле "Температура теплоносителя" заполнена неверно или не заполнено');
            exit;
          end;
        productHeat[i].agentTemp := StrToFloat(rowListHeat[i].agentTemp.Text);
        productHeat[i].selfHeat := 0;
      end
    else
      begin
        productHeat[i].startTemp := 0;
        productHeat[i].endTemp := 0;
        productHeat[i].agentTemp := 0;

        if not CheckString(rowListHeat[i].selfHeat.Text) then
          begin
            ShowMessage('Поле "Длительность самонагревания" заполнена неверно или не заполнено');
            exit;
          end;
        productHeat[i].selfHeat := StrToFloat(rowListHeat[i].selfHeat.Text);
      end;

    if rowListCool[i].check.Checked then
      begin
        if not CheckString(rowListCool[i].startTemp.Text) then
          begin
            ShowMessage('Поле "Начальная температура охлаждения" заполнена неверно или не заполнено');
            exit;
          end;
        productCool[i].startTemp := StrToFloat(rowListCool[i].startTemp.Text);

        if not CheckString(rowListCool[i].endTemp.Text) then
          begin
            ShowMessage('Поле "Конечная температура охлаждения" заполнена неверно или не заполнено');
            exit;
          end;
        productCool[i].endTemp := StrToFloat(rowListCool[i].endTemp.Text);

        if not CheckString(rowListHeat[i].agentTemp.Text) then
          begin
            ShowMessage('Поле "Температура хладагента" заполнена неверно или не заполнено');
            exit;
          end;
        productCool[i].agentTemp := StrToFloat(rowListCool[i].agentTemp.Text);
        productCool[i].selfCool := 0;
      end
    else
      begin
        productCool[i].startTemp := 0;
        productCool[i].endTemp := 0;
        productCool[i].agentTemp := 0;

        if not CheckString(rowListCool[i].selfHeat.Text) then
          begin
            ShowMessage('Поле "Длительность самоохлаждения" заполнено неверно или не заполнено');
            exit;
          end;
        productCool[i].selfCool := StrToFloat(rowListCool[i].selfHeat.Text);
      end;

      if not (CheckString(StringGrid13.Cells[1,i + 1])) or not (CheckString(StringGrid13.Cells[2,i + 1])) then
          begin
            ShowMessage('Таблица "Коэффициенты теплопередачи" заполнена неверно или не заполнена');
            exit;
          end;
      productHeatCapacity[i].ReactionMass := StrToFloat(StringGrid13.Cells[1,i + 1]);
      productHeatCapacity[i].Machine := StrToFloat(StringGrid13.Cells[2,i + 1]);

       if not (CheckString(StringGrid11.Cells[1,i + 1])) then
          begin
            ShowMessage('Таблица "Коэффициенты теплопередачи" заполнена неверно или не заполнена');
            exit;
          end;
      heatTransfer[i] := StrToFloat(StringGrid11.Cells[1,i + 1]);

      if not (CheckString(StringGrid11.Cells[1,i + 1])) then
          begin
            ShowMessage('Таблица "Длительность химечской реакции" заполнена неверно или не заполнена');
            exit;
          end;
      durationChemicalReact[i] := StrToFloat(StringGrid12.Cells[1,i + 1]);

      if not (CheckString(StringGrid14.Cells[1,i + 1])) or not (CheckString(StringGrid14.Cells[2,i + 1])) then
          begin
            ShowMessage('Таблица "Коэффициенты заполнения" заполнена неверно или не заполнена');
            exit;
          end;
      Split(';', StringGrid14.Cells[1,i + 1], StrList);
      machFillFactor[i].lower :=  StrToFloat(StrList[0]);
      machFillFactor[i].upper :=  StrToFloat(StrList[1]);
      Split(';', StringGrid14.Cells[2,i + 1], StrList);
      capacityFillFactor[i].lower :=  StrToFloat(StrList[0]);
      capacityFillFactor[i].upper :=  StrToFloat(StrList[1]);
  end;

  for i := 1 to Capacity.ColCount - 1 do
  begin
    if not (CheckString(Capacity.Cells[i, 0])) or not (CheckString(Capacity.Cells[i,1])) or not (CheckString(Capacity.Cells[i,2])) then
    begin
      ShowMessage('Таблица "Стандартный ряд емкостей" заполнена неверно или не заполнена');
      exit;
    end;
    pCapacity[i - 1].D :=  StrToFloat(Capacity.Cells[i,0]);
    pCapacity[i - 1].H := StrToFloat(Capacity.Cells[i,1]);
    pCapacity[i - 1].V := StrToFloat(Capacity.Cells[i,2]);
  end;

  for i := 1 to Apparatus.ColCount - 1 do
  begin
  if not (CheckString(Apparatus.Cells[i, 0])) or not (CheckString(Apparatus.Cells[i,1])) then
    begin
      ShowMessage('Таблица "Стандартный ряд аппаратов" заполнена неверно или не заполнена');
      exit;
    end;

    pMachine[i - 1].m  :=  StrToFloat(Apparatus.Cells[i,1]);
    pMachine[i - 1].V  := StrToFloat(Apparatus.Cells[i,0]);
  end;
//<----------------------------------------------------------------------------
//<------------------------- Checks end ---------------------------------------
//<----------------------------------------------------------------------------

  AddColoredLine(RichEdit1, 'Исходные данные:', clBlack);
  AddColoredLine(RichEdit1, '', clBlack);
  AddColoredLine(RichEdit1, 'Таблица размеров партий продуктов [кг]:', clBlack);
  AddColoredLine(RichEdit1, '#table#', clBlack);
  RichEdit1.Lines.LoadFromStream(getRichGrid(StringGrid1,RichEdit1));
  AddColoredLine(RichEdit1, '', clBlack);
  AddColoredLine(RichEdit1, 'Таблица плотностей входных потоков [кг/м^3]:', clBlack);
  AddColoredLine(RichEdit1, '#table#', clBlack);
  RichEdit1.Lines.LoadFromStream(getRichGrid(StringGrid2,RichEdit1));
  AddColoredLine(RichEdit1, '', clBlack);
  AddColoredLine(RichEdit1, 'Таблица плотностей добавочных потоков [кг/м^3]:', clBlack);
  AddColoredLine(RichEdit1, '#table#', clBlack);
  RichEdit1.Lines.LoadFromStream(getRichGrid(StringGrid3,RichEdit1));
  AddColoredLine(RichEdit1, '', clBlack);
  AddColoredLine(RichEdit1, 'Таблица коэффицинтов расхода:', clBlack);
  AddColoredLine(RichEdit1, '#table#', clBlack);
  RichEdit1.Lines.LoadFromStream(getRichGrid(StringGrid4,RichEdit1));
  AddColoredLine(RichEdit1, '', clBlack);
  AddColoredLine(RichEdit1, 'Таблица расходных коэффициентов:', clBlack);
  AddColoredLine(RichEdit1, '#table#', clBlack);
  RichEdit1.Lines.LoadFromStream(getRichGrid(StringGrid5,RichEdit1));
  AddColoredLine(RichEdit1, '', clBlack);
  AddColoredLine(RichEdit1, 'Таблица диаметров штуцеров [м]:', clBlack);
  AddColoredLine(RichEdit1, '#table#', clBlack);
  RichEdit1.Lines.LoadFromStream(getRichGrid(StringGrid6,RichEdit1));


  AddColoredLine(RichEdit1, '', clBlack);
  AddColoredLine(RichEdit1, 'Таблица коэффициентов теплопередачи [Вт/(К*м^2)]:', clBlack);
  AddColoredLine(RichEdit1, '#table#', clBlack);
  RichEdit1.Lines.LoadFromStream(getRichGrid(StringGrid11,RichEdit1));
  AddColoredLine(RichEdit1, '', clBlack);
  AddColoredLine(RichEdit1, 'Таблица длительностей химической реакции [ч]:', clBlack);
  AddColoredLine(RichEdit1, '#table#', clBlack);
  RichEdit1.Lines.LoadFromStream(getRichGrid(StringGrid12,RichEdit1));
  AddColoredLine(RichEdit1, '', clBlack);
  AddColoredLine(RichEdit1, 'Таблица теплоемкостей [Дж/(кг*К)]:', clBlack);
  AddColoredLine(RichEdit1, '#table#', clBlack);
  RichEdit1.Lines.LoadFromStream(getRichGrid(StringGrid13,RichEdit1));
  AddColoredLine(RichEdit1, '', clBlack);
  AddColoredLine(RichEdit1, 'Таблица стандартного ряда мерников:', clBlack);
  AddColoredLine(RichEdit1, '#table#', clBlack);
  RichEdit1.Lines.LoadFromStream(getRichGrid(Capacity, RichEdit1));
  AddColoredLine(RichEdit1, '', clBlack);
  AddColoredLine(RichEdit1, 'Таблица стандартного ряда аппаратов:', clBlack);
  AddColoredLine(RichEdit1, '#table#', clBlack);
  RichEdit1.Lines.LoadFromStream(getRichGrid(Apparatus,RichEdit1));
  AddColoredLine(RichEdit1, '', clBlack);
  AddColoredLine(RichEdit1, 'Таблица коэффицциентов заполнения аппаратов и мерников:', clBlack);
  AddColoredLine(RichEdit1, '#table#', clBlack);
  RichEdit1.Lines.LoadFromStream(getRichGrid(StringGrid14,RichEdit1));
  AddColoredLine(RichEdit1, '', clBlack);

  AddColoredLine(RichEdit1, 'Расчеты: ', clBlack);
  AddColoredLine(RichEdit1, '', clBlack);

//---------------------------------------------------------------------------->
//--------------------- calc: step matirial index ---------------------------->
//---------------------------------------------------------------------------->
  for i := 0 to numbOfProduct - 1 do
  begin
    DensRaw[i] := GetDensityRaw(
                                DensInpStr[i],
                                DensAddStr[i],
                                productExpFact[i].InpStr,
                                productExpFact[i].AddStr
                                );

    products[i].StepMapIndex :=  GetStepMapIndex(
                                      productExpFact[i].InpStr,
                                      productExpFact[i].AddStr,
                                      DensInpStr[i],
                                      DensAddStr[i]
                                      );


    products[i].DemUnit.left := RoundTo((products[i].StepMapIndex*
                                         products[i].pBatchSize)/
                                         machFillFactor[i].upper,-3);
    products[i].DemUnit.right := RoundTo((products[i].StepMapIndex*
                                          products[i].pBatchSize)/
                                          machFillFactor[i].lower,-3);

    end;

//<----------------------------------------------------------------------------
//<------------------ calc: step matirial index -------------------------------
//<----------------------------------------------------------------------------

//---------------------------------------------------------------------------->
//--------- check: is exist suitable size of machine for products ------------>
//---------------------------------------------------------------------------->
    for i := 0 to numbOfProduct - 1 do
      begin
        products[i].DemUnit.left := getMaxLimit(products);
        products[i].DemUnit.right := getMinLimit(products);
        products[i] := getAppSize(products[i],
                                  pMachine,
                                  machFillFactor[i].upper);
        if products[i].pMachine.V = 0 then
        begin
          AddColoredLine(RichEdit1,'Для продукта ' + IntTostr(i)
              + ' аппарат подходящего размера не найден ', clRed);
          AddColoredLine(RichEdit1, 'Пределы размера аппарата [м^3]: '
            +FloatToStr(products[i].DemUnit.left)+' <= V <= '
            +FloatToStr(products[i].DemUnit.right), clRed);
          exit;
          // ^^^^^^ if not exit and show it user ^^^^^^^^^^
        end;
      end;
//<----------------------------------------------------------------------------
//<---------- check: is exist suitable size of machine for products -----------
//<----------------------------------------------------------------------------


//---------------------------------------------------------------------------->
//-------- calc: suitable size of machine for all products ------------------->
//---------------------------------------------------------------------------->
    for i := 0 to numbOfProduct - 1 do
      begin
        AddColoredLine(RichEdit1, 'Для продукта №' + IntToStr(i+1) + ': ', clBlack);
        AddColoredLine(RichEdit1, '', clBlack);
        AddColoredLine(RichEdit1, 'Постадийный материальный индекс = ' +
                    FloatToStr(products[i].StepMapIndex) + ' м^3/кг', clBlack);
        AddColoredLine(RichEdit1, '', clBlack);
        AddColoredLine(RichEdit1, 'Подбор размера аппарата: ', clBlack);
        AddColoredLine(RichEdit1, 'Пределы размера аппарата [м^3]: '+
                        FloatToStr(products[i].DemUnit.left)+' <= V <= '+
                        FloatToStr(products[i].DemUnit.right), clBlack);
        AddColoredLine(RichEdit1, 'Подобран аппарат размером: V = '+
                          FloatToStr(products[i].pMachine.V) + ' м^3', clBlack);
        AddColoredLine(RichEdit1, 'Реальный коэффициент заполнения аппарата: '+
                          FloatToStr(products[i].pRealFillFactor.Real), clBlack);
      end;
//<----------------------------------------------------------------------------
//<---------- calc: suitable size of machine for all products -----------------
//<----------------------------------------------------------------------------

//---------------------------------------------------------------------------->
//-------- calc: general size of machine for all products -------------------->
//------------------- and calc batch sizes ----------------------------------->
//---------------------------------------------------------------------------->

      mainEqipment.pMachine.V = getMaxSizeOfMachine(products);
      AddColoredLine(RichEdit1, 'Выбран общий аппарат размером = ' +
                    FloatToStr(mainEqipment.pMachine.V) + ' м^3', clBlack);

      for i := 0 to numbOfProduct - 1 do
      begin
        products[i].pRealFillFactor.Real := getReallFillFactor(
                                            products[i].StepMapIndex,
                                            products[i].pBatchSize,
                                            mainEqipment.pMachine.V);
        AddColoredLine(RichEdit1, 'Для продукта №' + IntToStr(i+1)
                                                            + ': ', clBlack);
        AddColoredLine(RichEdit1, '', clBlack);
        AddColoredLine(RichEdit1, 'Реальный коэффициент заполнения аппарата: '+
                          FloatToStr(products[i].pRealFillFactor.Real), clBlack);
      end;
//------------------- Check Fill factor --------------------------------------->
      for i := 0 to numbOfProduct - 1 do
      begin
        if products[i].pRealFillFactor.Real < machFillFactor[i].lower then
        begin
        AddColoredLine(RichEdit1, 'Для продукта №' + IntToStr(i+1) + ': ', clRed);
        AddColoredLine(RichEdit1,'Реальный коэффициент заполнения меньше нижнего коэф. заполнения', clRed);

        products[i].pBatchSize := getMaxBatchSize(mainEqipment.pMachine.V,
                                                    DensRaw[i],
                                                    1, //Magic number
                                                    machFillFactor[i]);

        AddColoredLine(RichEdit1, 'Пересчет размера партии: '
                              + FloatToStr(products[i].pBatchSize), clBlack);

        products[i].VolumeRawStr := getVolume(productExpFact[i].InpStr,
                                            products[i].pBatchSize,
                                            DensRaw[i]);

        AddColoredLine(RichEdit1, 'Пересчет объема сырья = '
                      + FloatToStr(products[i].VolumeRawStr) + ' м^3', clBlack);


        products[i].pRealFillFactor.Real := getReallFillFactor(
                                            products[i].StepMapIndex,
                                            products[i].pBatchSize,
                                            mainEqipment.pMachine.V);

        AddColoredLine(RichEdit1, 'Реальный коэффициент заполнения аппарата: '
                        + FloatToStr(products[i].pRealFillFactor.Real), clBlack);

        end;
      end;
//<------------------- Check Fill factor ---------------------------------------

//<----------------------------------------------------------------------------
//<-------- calc: general size of machine for all products --------------------
//<------------------- and calc batch sizes -----------------------------------
//<----------------------------------------------------------------------------

//---------------------------------------------------------------------------->
//----- calc: suitable size of capacity for add stream for all products ------>
//---------------------------------------------------------------------------->


    for i := 0 to numbOfProduct - 1 do
      begin
        products[i].VolumeAddStr := getVolume(productExpFact[i].AddStr,
                                              products[i].pBatchSize,
                                              DensAddStr[i]
                                              );

        AddColoredLine(RichEdit1, '', clBlack);
        AddColoredLine(RichEdit1, 'Для продукта №' + IntToStr(i+1) + ': ', clBlack);
        AddColoredLine(RichEdit1, 'Подбор размера емкости для добавочного потока: ', clBlack);
        AddColoredLine(RichEdit1, 'Объем добавочного потока: V = '
                      + FloatToStr(products[i].VolumeAddStr) + ' м^3', clBlack);

        products[i].pCapacityForAddStr := getCapacitySize(
                                   products[i],
                                   products[i].VolumeAddStr,
                                   capacityFillFactor[i],
                                   pCapacity
                                   );

        if products[i].pCapacityForAddStr.V = 0 then
        begin
          AddColoredLine(RichEdit1, 'Мерник подходящего размера не найден ', clRed);
          AddColoredLine(RichEdit1, 'Добавьте мерник подходящего размера в таблицу "Стандартный ряд мерников" ', clRed);
          AddColoredLine(RichEdit1, 'Объем мерника должен быть не менее '
            +FloatToStr(products[i].VolumeAddStr*capacityFillFactor[i].lower)
            +' м^3 и не более '
            +FloatToStr(products[i].VolumeAddStr*capacityFillFactor[i].upper)
            +'м^3', clRed);
          exit;
        end;

        AddColoredLine(RichEdit1, 'Подобран мерник размером: V = '
              + FloatToStr(products[i].pCapacityForAddStr.V) + ' м^3', clBlack);

        products[i].pRealFillFactor.AddStr := RoundTo(products[i].VolumeAddStr/
                                                  products[i].pCapacityForAddStr.V,
                                                  -3);

        AddColoredLine(RichEdit1, 'Реальный коэффициент заполнения емкости: '
                    + FloatToStr(products[i].pRealFillFactor.AddStr), clBlack);

        end;

//-----------------------------------------------------------------------------
//----- calc: suitable size of capacity for add stream for all products -------
//-----------------------------------------------------------------------------

        if products[i].pRealFillFactor.AddStr < capacityFillFactor[i].lower then
        begin
      AddColoredLine(RichEdit1, 'Реальный коэффициент заполнения меньше нижнего коэф. заполнения', clBlack);

      products[i].pBatchSize := getMaxBatchSize(products[i].pCapacityForAddStr.V,
                                                    DensAddStr[i],
                                                    productExpFact[i].AddStr,
                                                    capacityFillFactor[i]);

      AddColoredLine(RichEdit1, 'Пересчет размера партии: '+FloatToStr(products[i].pBatchSize), clBlack);

      products[i].VolumeAddStr := getVolume(productFlowFact[i].AddStr,
                                            products[i].pBatchSize,
                                            DensAddStr[i]);

      AddColoredLine(RichEdit1, 'Пересчет объема добавочного потока = ' + FloatToStr(products[i].VolumeAddStr) + ' м^3', clBlack);

      products[i].pCapacityForAddStr := getCapacitySize(products[i],
                                     products[i].VolumeAddStr,
                                     capacityFillFactor[i],
                                     pCapacity);

      AddColoredLine(RichEdit1, 'Реальный коэффициент заполнения емкости: '+ FloatToStr(products[i].pRealFillFactor.AddStr), clBlack);
        end;

        begin

    products[i].VolumeInputStr := getVolume(productExpFact[i].InpStr,
                                            products[i].pBatchSize,
                                            DensInpStr[i]);
    AddColoredLine(RichEdit1, '', clBlack);
    AddColoredLine(RichEdit1, 'Подбор размера емкости для входящего потока: ', clBlack);
    AddColoredLine(RichEdit1, 'Объем входящего потока: V = ' + FloatToStr(products[i].VolumeInputStr) + ' м^3', clBlack);

    products[i].pCapacityForRawStr := getCapacitySize(products[i],
                                     products[i].VolumeInputStr,
                                     capacityFillFactor[i],
                                     pCapacity);

    if products[i].pCapacityForRawStr.V = 0 then
      begin
        AddColoredLine(RichEdit1, 'Емкость подходящего размера не найдена ', clRed);
        break;
      end;

    AddColoredLine(RichEdit1, 'Подобрана емкость размером V = : '+ FloatToStr(products[i].pCapacityForRawStr.V) + ' м^3', clBlack);

    products[i].pRealFillFactor.Raw := RoundTo(products[i].VolumeInputStr/
                                                  products[i].pCapacityForRawStr.V,
                                                  -3);

    AddColoredLine(RichEdit1, 'Реальный коэффициент заполнения емкости: '+ FloatToStr(products[i].pRealFillFactor.Raw), clBlack);

    if products[i].pRealFillFactor.Raw > capacityFillFactor[i].upper then
    begin

      AddColoredLine(RichEdit1,'Реальный коэффициент заполнения больше верхнего коэф. заполнения', clRed);

      products[i].pBatchSize := getMaxBatchSize(products[i].pCapacityForRawStr.V,
                                                    DensInpStr[i],
                                                    productExpFact[i].InpStr,
                                                    capacityFillFactor[i]);

      AddColoredLine(RichEdit1, 'Пересчет размера партии: '+FloatToStr(products[i].pBatchSize), clBlack);

      products[i].VolumeRawStr := getVolume(productExpFact[i].InpStr,
                                            products[i].pBatchSize,
                                            DensInpStr[i]);

      AddColoredLine(RichEdit1, 'Пересчет объема входящего потока V = ' + FloatToStr(products[i].VolumeRawStr) + ' м^3', clBlack);


      products[i].pRealFillFactor.Raw := RoundTo(products[i].VolumeInputStr/
                                                  products[i].pCapacityForRawStr.V,
                                                  -3);

      AddColoredLine(RichEdit1, 'Реальный коэффициент заполнения емкости: '+ FloatToStr(products[i].pRealFillFactor.Raw), clBlack);

    end;

      end;

    AddColoredLine(RichEdit1, '', clBlack);
    AddColoredLine(RichEdit1, 'Расчет длительностей: ', clBlack);
    InitHeight := products[i].pRealFillFactor.Raw*products[i].pCapacityForRawStr.H;

    products[i].durationDownloadInputStr := GetDuration(products[i].pCapacityForRawStr.D,
                                                        InitHeight,
                                                        pDSht[i].Raw,
                                                        productFlowFact[i].InpStr);

    InitHeight := products[i].pRealFillFactor.AddStr*products[i].pCapacityForAddStr.H;

    products[i].durationDownloadAddStr := GetDuration(products[i].pCapacityForAddStr.D,
                                                        InitHeight,
                                                        pDSht[i].AddStr,
                                                        productFlowFact[i].AddStr);

    DMachine := Power(2*products[i].pMachine.V/3.14, 1/3);

    InitHeight := products[i].pRealFillFactor.Real*DMachine*StrTofloat(EditRatioV_H.Text);

    products[i].durationUploadOutStr := GetDuration(
                                                        DMachine,
                                                        InitHeight,
                                                        pDSht[i].Unload,
                                                        productFlowFact[i].OutStr);

    AddColoredLine(RichEdit1, '', clBlack);
    AddColoredLine(RichEdit1, 'Длительность загрузки входного потока = ' + FloatToStr(products[i].durationDownloadInputStr)+ ' с', clBlack);
    AddColoredLine(RichEdit1, 'Длительность загрузки доб. потока = ' + FloatToStr(products[i].durationDownloadAddStr)+ ' с', clBlack);
    AddColoredLine(RichEdit1, 'Длительность выгрузки = ' + FloatToStr(products[i].durationUploadOutStr)+ ' с', clBlack);

    DMachine := Power(2*products[i].pMachine.V/3.14, 1/3);

    SurfaceTrans := 3.14*DMachine*InitHeight + Power(DMachine,2)*3.14/4;

    if rowListHeat[i].check.Checked then
      begin
        MPHeat := GetMotPowHeat(productHeat[i].startTemp,
                                productHeat[i].endTemp,
                                productHeat[i].agentTemp);

        products[i].DurationHeat := getDurationHeat(
                                          products[i].pBatchSize,
                                          productHeatCapacity[i].ReactionMass,
                                          productHeatCapacity[i].Machine,
                                          products[i].pMachine.m,
                                          productHeat[i].endTemp,
                                          productHeat[i].startTemp,
                                          SurfaceTrans,
                                          MPHeat,
                                          heatTransfer[i]);
      end
    else
    begin
      products[i].DurationHeat := productHeat[i].selfHeat*3600;
    end;

     AddColoredLine(RichEdit1, 'Длительность нагревания = ' + FloatToStr(products[i].durationHeat)+ ' с', clBlack);

    if rowListCool[i].check.Checked then
      begin
        MPHeat := GetMotPowCool(productCool[i].startTemp,
                                productCool[i].endTemp,
                                productCool[i].agentTemp);

        products[i].durationCool := getDurationHeat(
                                          products[i].pBatchSize,
                                          productHeatCapacity[i].ReactionMass,
                                          productHeatCapacity[i].Machine,
                                          products[i].pMachine.m,
                                          productCool[i].startTemp,
                                          productCool[i].endTemp,
                                          SurfaceTrans,
                                          MPHeat,
                                          heatTransfer[i]);
      end
    else
    begin
      products[i].durationCool := productCool[i].selfCool*3600;
    end;

    AddColoredLine(RichEdit1, 'Длительность охлаждения = ' + FloatToStr(products[i].durationCool)+ ' с', clBlack);

    products[i].durationChemicalReact := durationChemicalReact[i]*3600;

    products[i].durationOverall := RoundTo((products[i].durationChemicalReact +
                                    products[i].durationHeat +
                                    products[i].durationCool +
                                    products[i].durationDownloadInputStr +
                                    products[i].durationDownloadAddStr +
                                    products[i].durationUploadOutStr)/3600, -3);
    AddColoredLine(RichEdit1, 'Общая длительность ТС получения 1 партии продукта = ' + FloatToStr(products[i].durationOverall)+ ' ч', clBlack);
    AddColoredLine(RichEdit1, '', clBlack);
    AddColoredLine(RichEdit1, '', clBlack);
    AddColoredLine(RichEdit1, '', clBlack);




end;

end.
