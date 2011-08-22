unit mapeditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Map;

type
  TMainEdForm = class(TForm)
    Timer1: TTimer;
    GroupBox2: TGroupBox;
    GroupBox1: TGroupBox;
    TileList: TComboBox;
    Fill: TButton;
    GroupBox3: TGroupBox;
    MonsterList: TComboBox;
    DeleteMonster: TCheckBox;
    GroupBox4: TGroupBox;
    mapname: TEdit;
    MapList: TListBox;
    Button1: TButton;
    Save: TButton;
    GroupBox5: TGroupBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FillClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure DrawMap;
    procedure SaveClick(Sender: TObject);
    procedure MapListClick(Sender: TObject);
    function LoadSpecialMaps : boolean;
    function SaveSpecialMaps : boolean;
    procedure AddInfo;
    procedure TakeInfo;
  private
  public
  end;

const
  MaxMaps = 5;

type
  TMaps = record
    id : byte;                 // Номер 
    name : string[40];         // Название карты
    Map : TMap;                // Сама карта
    Loc : array[1..4] of byte; // Окружающие ее карты (1-Вверх,2-Вниз,3-Влево,4-Вправо)
  end;

var
  MainEdForm: TMainEdForm;
  Screen : TBitMap;
  SpecialMaps : array[1..MaxMaps] of TMaps;
  Now : byte;

implementation

{$R *.dfm}

uses
  Cons, Tile, Player, Monsters, Utils;

procedure TMainEdForm.FormCreate(Sender: TObject);
const
  VW = 480; // Место для менюшек
var
  i : byte;
begin
  // Рамеры окна
  ClientWidth := MapX * CharX + VW;
  ClientHeight := MapY * CharY;
  // Создаем картинку
  Screen := TBitMap.Create;
  Screen.Width := MapX * CharX;
  Screen.Height := MapY * CharY;
  Screen.Canvas.Font.Name := FontName;
  // Компоненты
  GroupBox2.Top := 10;
  GroupBox2.Left := MapX * CharX + 10;
  // Тайлы
  for i:=1 to LevelTilesAmount do
    TileList.Items.Add(TilesData[i].name);
  // Монстры
  for i:=1 to MonstersAmount do
    MonsterList.Items.Add(MonstersData[i].name1);
end;

{ Вывести карту }
procedure TMainEdForm.FormPaint(Sender: TObject);
begin
  // Заполняем картинку черным цветом
  Screen.Canvas.Brush.Color := 0;
  Screen.Canvas.FillRect(Rect(0, 0, MapX * CharX, MapY * CharY));
  // Выводим карту
  DrawMap;
  // Отобразить
  Canvas.StretchDraw(Rect(0, 0, MapX * CharX, MapY * CharY), Screen);
end;

{ Залить }
procedure TMainEdForm.FillClick(Sender: TObject);
var
  x, y : byte;
begin
  for x:=1 to MapX do
    for y:=1 to MapY do
      M.Tile[x,y] := TileList.ItemIndex + 1;
end;

{ Обновлять по таймеру}
procedure TMainEdForm.Timer1Timer(Sender: TObject);
begin
  OnPaint(Sender);
end;

{ Вывести карту }
procedure TMainEdForm.DrawMap;
var
  x, y    : integer;
  color      : longword;
  char       : string[1];
begin
  for x:=1 to MapX do
    for y:=1 to MapY do
      with Screen.Canvas do
      begin
        color := 255;
        Brush.Color := 0;
        // Тайл
        case M.Blood[x,y] of
          0 : color := TilesData[M.Tile[x,y]].color;
          1 : color := cLIGHTRED;
          2 : color := cRED;
        end;
        char := TilesData[M.Tile[x,y]].char;
        // Монстры
        if M.MonP[x,y] > 0 then
        begin
            if M.MonP[x,y] = 1 then
            begin
              color := cLIGHTBLUE;
              char := '@';
              if pc.felldown then color:= cGRAY;
            end else
              begin
                color := MonstersData[M.MonL[M.MonP[x,y]].id].color;
                if color = cRANDOM then
                  color := MyRGB(Random(155)+100, Random(155)+100, Random(155)+100);
                if M.MonL[M.MonP[x,y]].felldown then color:= cGRAY;
                char := MonstersData[M.MonL[M.MonP[x,y]].id].char;
              end;
        end;
        // Вывести символ
        Font.Color := color;
        TextOut((x-1)*CharX, (y-1)*CharY, char);
      end;
end;

{ Сохранить все}
procedure TMainEdForm.SaveClick(Sender: TObject);
begin
  AddInfo;
  SaveSpecialMaps;
end;

{ Выбрать карту }
procedure TMainEdForm.MapListClick(Sender: TObject);
begin
  Now := MapList.ItemIndex;
  DeleteMonster.Caption := IntToStr(Now);
end;

{ Загрузить карты }
function TMainEdForm.LoadSpecialMaps : boolean;
var
  f : file;
  i,kol : byte;
begin
  AssignFile(f,'data/maps.dp');
  {$I-}
  Reset(f,1);
  {$I+}
  if IOResult = 0 then
  begin
    Result := true;
    BlockRead(f, kol, SizeOf(kol));
    for i:=1 to kol do
      BlockRead(f, SpecialMaps[i], SizeOf(SpecialMaps[i]));
    CloseFile(f);
  end else
    Result := false;
end;

{ Сохранить карты }
function TMainEdForm.SaveSpecialMaps : boolean;
var
  f : file;
  i,kol : byte;
begin
  CreateDir('data');
  AssignFile(f,'data/maps.dp');
  {$I-}
  Rewrite(f,1);
  kol := 0;
  for i:=1 to MaxMaps do
    if SpecialMaps[i].id > 0 then
      inc(kol);
  BlockWrite(f, kol, SizeOf(kol));
  for i:=1 to kol do
    BlockWrite(f, SpecialMaps[i], SizeOf(SpecialMaps[i]));
  CloseFile(f);
  {$I+}
  if IOResult <> 0 then
    Result := false else
      Result := true;
end;

{ Добавить инфу в текущую карту }
procedure TMainEdForm.AddInfo;
begin
  with SpecialMaps[now] do
  begin
    name := mapname.Text;
    loc[1] := StrToInt(Edit1.Text);
    loc[2] := StrToInt(Edit2.Text);
    loc[3] := StrToInt(Edit3.Text);
    loc[4] := StrToInt(Edit4.Text);
  end;
end;

{ Взять инфу из карты }
procedure TMainEdForm.TakeInfo;
begin
  with SpecialMaps[now] do
  begin
    mapname.Text := name;
    Edit1.Text := IntToStr(loc[1]);
    Edit2.Text := IntToStr(loc[2]);
    Edit3.Text := IntToStr(loc[3]);
    Edit4.Text := IntToStr(loc[4]);
  end;
end;

end.
