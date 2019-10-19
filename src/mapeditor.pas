unit mapeditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, Map, Menus, Cons;

type
  TMainEdForm = class(TForm)
    GroupBox2: TGroupBox;
    GroupBox1: TGroupBox;
    GroupBox4: TGroupBox;
    mapname: TEdit;
    Save: TButton;
    GroupBox5: TGroupBox;
    up: TEdit;
    down: TEdit;
    left: TEdit;
    right: TEdit;
    coord: TLabel;
    ItemsBox: TListBox;
    SetTiles: TSpeedButton;
    SetMonsters: TSpeedButton;
    Fill: TSpeedButton;
    GroupBox3: TGroupBox;
    MapList: TListBox;
    Button5: TButton;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    GroupBox6: TGroupBox;
    Button6: TButton;
    CheckBox1: TCheckBox;
    Button7: TButton;
    pregen1: TComboBox;
    cool1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    type1: TEdit;
    CheckBox3: TCheckBox;
    pregen3: TComboBox;
    cool3: TEdit;
    type3: TEdit;
    CheckBox4: TCheckBox;
    pregen4: TComboBox;
    cool4: TEdit;
    type4: TEdit;
    CheckBox5: TCheckBox;
    pregen5: TComboBox;
    cool5: TEdit;
    type5: TEdit;
    CheckBox6: TCheckBox;
    pregen6: TComboBox;
    cool6: TEdit;
    type6: TEdit;
    CheckBox7: TCheckBox;
    pregen7: TComboBox;
    cool7: TEdit;
    type7: TEdit;
    CheckBox9: TCheckBox;
    pregen9: TComboBox;
    cool9: TEdit;
    type9: TEdit;
    CheckBox2: TCheckBox;
    pregen2: TComboBox;
    cool2: TEdit;
    type2: TEdit;
    CheckBox8: TCheckBox;
    pregen8: TComboBox;
    cool8: TEdit;
    type8: TEdit;
    CheckBox10: TCheckBox;
    pregen10: TComboBox;
    cool10: TEdit;
    type10: TEdit;
    N4: TMenuItem;
    Memo1: TMemo;
    CheckBox11: TCheckBox;
    BloodMode: TComboBox;
    Label3: TLabel;
    GroupBox7: TGroupBox;
    Button1: TButton;
    Pregen: TComboBox;
    ListBox1: TListBox;
    SpeedButton1: TSpeedButton;
    numberchange: TComboBox;
    number: TLabel;
    GroupBox8: TGroupBox;
    Button2: TButton;
    Button3: TButton;
    relation: TComboBox;
    Label4: TLabel;
    Label5: TLabel;
    SpeedButton2: TSpeedButton;
    DungeonName: TEdit;
    RandomName: TCheckBox;
    Timer1: TTimer;
    SetItems: TSpeedButton;
    N5: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FillClick(Sender: TObject);
    procedure DrawMap;
    procedure SaveClick(Sender: TObject);
    procedure MapListClick(Sender: TObject);
    function LoadSpecialMaps: boolean;
    function SaveSpecialMaps: boolean;
    procedure AddInfo;
    procedure TakeInfo;
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure RefreshItemList;
    procedure SetTilesClick(Sender: TObject);
    procedure SetMonstersClick(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure RefreshMapList;
    procedure Button5Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure RandomNameClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure SetItemsClick(Sender: TObject);
    procedure N5Click(Sender: TObject);
  private
  public
  end;

const
  MaxMaps = 255;

type
  TLevel = record
    IsHere: boolean; // Нужен ли здесь уровень вообще
    PregenLevel: byte; // Если > 0, значит это спец. уровень и вся остальная инфа не нужна
    CoolLevel: byte; // Уровень крутости
    DungeonType: byte; // Тип генерируемого уровня
    Reserv: array [1 .. 20] of byte; // Резерв
  end;

  TLadder = record
    Name: string[17]; // Название подзмелья
    X, Y: byte; // Расположение лестницы
    Levels: array [1 .. MaxDepth] of TLevel; // Характеристики каждого уровня
  end;

  TMaps = record
    Name: string[40]; // Название карты
    ShowName: boolean; // Отображать название спец. карты
    Map: TMap; // Сама карта
    Loc: array [1 .. 4] of byte; // Окружающие ее карты (1-Вверх,2-Вниз,3-Влево,4-Вправо)
    Ladders: array [1 .. MaxLadders] of TLadder; // Свойства лестниц вниз
    LadderUp: byte; // Куда ведет лестница вверх
  end;

var
  MainEdForm: TMainEdForm;
  EdScreen: TBitmap;
  SpecialMaps: array [1 .. MaxMaps] of TMaps;
  NowMap, NowElement, N: byte;
  CurX, CurY: Integer;
  WaitForLadderClick, WaitForMonsterClick: boolean;
  NowLadder: byte;

implementation

{$R *.dfm}

uses
  Tile, Player, Utils, Monsters, conf, mbox, items;

procedure TMainEdForm.FormCreate(Sender: TObject);
const
  VW = 505; // Место для менюшек
begin
  if not LoadSpecialMaps then
  begin
    MsgBox('Ошибка загрузки пакета карт!');
    NowMap := 0;
  end;
  WaitForLadderClick := False;
  RefreshMapList;
  NowElement := 1;
  // Рамеры окна
  ClientWidth := MapX * CharX + VW;
  ClientHeight := MapY * CharY;
  // Создаем картинку
  EdScreen := TBitmap.Create;
  with EdScreen do
  begin
    Width := MapX * CharX;
    Height := MapY * CharY;
    Canvas.Font.Name := FontMsg;
    Canvas.Font.Size := FontSize;
    case FontStyle of
      1:
        Canvas.Font.Style := [fsBold];
      2:
        Canvas.Font.Style := [fsItalic];
      3:
        Canvas.Font.Style := [fsBold, fsItalic];
    else
      Canvas.Font.Style := [];
    end;
  end;
  // Компоненты
  GroupBox2.Top := 0;
  GroupBox2.left := MapX * CharX + 10;
  GroupBox6.left := GroupBox2.left;
  GroupBox7.left := GroupBox2.left;
  GroupBox8.left := GroupBox2.left;

  // Обновить список
  RefreshItemList;
  OnPaint(nil);
end;

{ Вывести карту }
procedure TMainEdForm.FormPaint(Sender: TObject);
begin
  // Заполняем картинку черным цветом
  EdScreen.Canvas.Brush.Color := 0;
  EdScreen.Canvas.FillRect(Rect(0, 0, MapX * CharX, MapY * CharY));
  // Выводим карту
  DrawMap;
  // Отобразить
  Canvas.StretchDraw(Rect(0, 0, MapX * CharX, MapY * CharY), EdScreen);
end;

{ Залить }
procedure TMainEdForm.FillClick(Sender: TObject);
var
  X, Y: byte;
begin
  if NowElement = 1 then
  begin
    for X := 1 to MapX do
      for Y := 1 to MapY do
        M.Tile[X, Y] := ItemsBox.ItemIndex + 1;
    OnPaint(Sender);
  end;
end;

{ Вывести карту }
procedure TMainEdForm.DrawMap;
var
  X, Y: Integer;
  Color, back: longword;
  char: string[1];
begin
  for X := 1 to MapX do
    for Y := 1 to MapY do
      with EdScreen.Canvas do
      begin
        Color := 255;
        back := 0;
        Brush.Color := 0;
        // Тайл
        case M.Blood[X, Y] of
          0:
            Color := RealColor(TilesData[M.Tile[X, Y]].Color);
          1:
            Color := cLIGHTRED;
          2:
            Color := cRED;
        end;
        char := TilesData[M.Tile[X, Y]].char;
        back := Darker(RealColor(TilesData[M.Tile[X, Y]].Color), 92);
        // Предметы
        if M.Item[X, Y].id > 0 then
        begin
          Color := RealColor(ItemsData[M.Item[X, Y].id].Color);
          char := ItemTypeData[ItemsData[M.Item[X, Y].id].vid].symbol;
        end;
        // Монстры
        if M.MonP[X, Y] > 0 then
        begin
          if M.MonP[X, Y] = 1 then
          begin
            Color := cLIGHTBLUE;
            char := '@';
            if pc.felldown then
              Color := cGRAY;
          end
          else
          begin
            Color := RealColor(MonstersData[M.MonL[M.MonP[X, Y]].id].Color);
            if M.MonL[M.MonP[X, Y]].felldown then
              Color := cGRAY;
            if M.MonP[X, Y] = ListBox1.ItemIndex + 1 then
              back := MyRGB(150, 0, 0);
            char := MonstersData[M.MonL[M.MonP[X, Y]].id].char;
          end;
        end;
        // Вывести символ
        Brush.Color := back;
        Font.Color := Color;
        TextOut((X - 1) * CharX, (Y - 1) * CharY, char);

        Pen.Color := clYellow;
        Brush.Style := bsClear;
        Rectangle((CurX - 1) * CharX - 1, (CurY - 1) * CharY - 1, CurX * CharX + 1, CurY * CharY + 1);
      end;
end;

{ Перезаписать }
procedure TMainEdForm.Button5Click(Sender: TObject);
begin
  if NowMap = 0 then
    MsgBox('Не выбрана карта!')
  else
  begin
    SpecialMaps[NowMap].Map.Special := NowMap;
    SpecialMaps[NowMap].Map := M;
    AddInfo;
    SaveSpecialMaps;
    RefreshMapList;
  end;
end;

{ Добавить карту }
procedure TMainEdForm.SaveClick(Sender: TObject);
var
  i: byte;
begin
  for i := 1 to MaxMaps do
    if SpecialMaps[i].Map.Special = 0 then
      break;
  NowMap := i;
  Button2.Caption := IntToStr(NowMap);
  SpecialMaps[NowMap].Map := M;
  SpecialMaps[NowMap].Map.Special := NowMap;
  AddInfo;
  RefreshMapList;
end;

{ Выбрать карту }
procedure TMainEdForm.MapListClick(Sender: TObject);
var
  i: byte;
begin
  NowMap := MapList.ItemIndex + 1;
  M.Clear;
  M := SpecialMaps[NowMap].Map;
  TakeInfo;
  OnPaint(Sender);
  ListBox1.Clear;
  for i := 1 to 255 do
    ListBox1.items.Add(IntToStr(i) + ' - ' + IntToStr(M.MonL[i].id));
end;

{ Загрузить карты }
function TMainEdForm.LoadSpecialMaps: boolean;
var
  f: file;
  i, kol, M, k, X, Y, z: byte;
begin
  Result := False;
  AssignFile(f, 'data/maps.dm');
{$I-}
  Reset(f, 1);
{$I+}
  if IOResult = 0 then
  begin
    Result := TRUE;
    BlockRead(f, kol, SizeOf(kol));
    for i := 1 to kol do
    begin
      // Номер и название карты
      BlockRead(f, SpecialMaps[i].Map.Special, SizeOf(SpecialMaps[i].Map.Special));
      BlockRead(f, SpecialMaps[i].Name, SizeOf(SpecialMaps[i].Name));
      BlockRead(f, SpecialMaps[i].ShowName, SizeOf(SpecialMaps[i].ShowName));
      // Карта - тайлы, кровь, монстры, предметы
      BlockRead(f, SpecialMaps[i].Map.Tile, SizeOf(SpecialMaps[i].Map.Tile));
      BlockRead(f, SpecialMaps[i].Map.Blood, SizeOf(SpecialMaps[i].Map.Blood));
      // Лестницы
      BlockRead(f, SpecialMaps[i].Ladders, SizeOf(SpecialMaps[i].Ladders));
      BlockRead(f, SpecialMaps[i].LadderUp, SizeOf(SpecialMaps[i].LadderUp));
      // Соседние локации
      BlockRead(f, SpecialMaps[i].Loc, SizeOf(SpecialMaps[i].Loc));
    end;
    CloseFile(f);
  end;
  // Монстры
  AssignFile(f, 'data/monsters.dm');
{$I-}
  Reset(f, 1);
{$I+}
  if IOResult = 0 then
  begin
    if Result = TRUE then
      Result := TRUE;
    for i := 1 to kol do
    begin
      // Читаем кол-во монстров
      BlockRead(f, k, SizeOf(k));
      BlockRead(f, SpecialMaps[i].Map.MonP, SizeOf(SpecialMaps[i].Map.MonP));
      if k > 0 then
        for M := 1 to k do
          with SpecialMaps[i].Map.MonL[M] do
          begin
            BlockRead(f, id, SizeOf(id));
            BlockRead(f, relation, SizeOf(relation));
          end;
    end;
    CloseFile(f);
  end
  else
    Result := False;
  // Предметы
  AssignFile(f, 'data/items.dm');
{$I-}
  Reset(f, 1);
{$I+}
  if IOResult = 0 then
  begin
    if Result = TRUE then
      Result := TRUE;
    for i := 1 to kol do
    begin
      z := 0;
      for X := 1 to MapX do
        for Y := 1 to MapY do
        begin
          BlockRead(f, z, 1);
          if z > 0 then
            BlockRead(f, SpecialMaps[i].Map.Item, SizeOf(SpecialMaps[i].Map.Item));
        end;
    end;
    CloseFile(f);
  end
  else
    Result := False;
end;

{ Сохранить карты }
function TMainEdForm.SaveSpecialMaps: boolean;
var
  f: file;
  i, kol, M, k, X, Y, z, b: byte;
begin
  CreateDir('data');
  // Локации
  AssignFile(f, 'data/maps.dm');
{$I-}
  Rewrite(f, 1);
  for kol := 1 to MaxMaps do
    if SpecialMaps[kol].Map.Special = 0 then
      break;
  kol := kol - 1;
  BlockWrite(f, kol, SizeOf(kol));
  if kol > 0 then
    for i := 1 to kol do
    begin
      // Номер и название карты
      BlockWrite(f, SpecialMaps[i].Map.Special, SizeOf(SpecialMaps[i].Map.Special));
      BlockWrite(f, SpecialMaps[i].Name, SizeOf(SpecialMaps[i].Name));
      BlockWrite(f, SpecialMaps[i].ShowName, SizeOf(SpecialMaps[i].ShowName));
      // Карта - тайлы, кровь, монстры, предметы
      BlockWrite(f, SpecialMaps[i].Map.Tile, SizeOf(SpecialMaps[i].Map.Tile));
      BlockWrite(f, SpecialMaps[i].Map.Blood, SizeOf(SpecialMaps[i].Map.Blood));
      // Лестницы
      BlockWrite(f, SpecialMaps[i].Ladders, SizeOf(SpecialMaps[i].Ladders));
      BlockWrite(f, SpecialMaps[i].LadderUp, SizeOf(SpecialMaps[i].LadderUp));
      // Соседние локации
      BlockWrite(f, SpecialMaps[i].Loc, SizeOf(SpecialMaps[i].Loc));
    end;
  CloseFile(f);
{$I+}
  if IOResult <> 0 then
    Result := False
  else
    Result := TRUE;
  // Монстры
  AssignFile(f, 'data/monsters.dm');
{$I-}
  Rewrite(f, 1);
  if kol > 0 then
    for i := 1 to kol do
    begin
      // Определяем кол-во монстров
      for k := 2 to 255 do
        if SpecialMaps[i].Map.MonL[k].id = 0 then
          break;
      k := k - 1;
      BlockWrite(f, k, SizeOf(k));
      BlockWrite(f, SpecialMaps[i].Map.MonP, SizeOf(SpecialMaps[i].Map.MonP));
      // Монстров записываем поочереди
      if k > 0 then
        for M := 1 to k do
        begin
          with SpecialMaps[i].Map.MonL[M] do
          begin
            BlockWrite(f, id, SizeOf(id));
            BlockWrite(f, relation, SizeOf(relation));
          end;
        end;
    end;
  CloseFile(f);
{$I+}
  if IOResult <> 0 then
    Result := False
  else
    Result := TRUE;
  // Предметы
  AssignFile(f, 'data/items.dm');
{$I-}
  Rewrite(f, 1);
  if kol > 0 then
    for i := 1 to kol do
    begin
      z := 0;
      for X := 1 to MapX do
        for Y := 1 to MapY do
          if SpecialMaps[i].Map.Item[X, Y].id = 0 then
            BlockWrite(f, z, 1)
          else
            BlockWrite(f, SpecialMaps[i].Map.Item, SizeOf(SpecialMaps[i].Map.Item));
    end;
  CloseFile(f);
{$I+}
  if IOResult <> 0 then
    Result := False
  else
    Result := TRUE;
end;

{ Добавить инфу в текущую карту }
procedure TMainEdForm.AddInfo;
begin
  with SpecialMaps[NowMap] do
  begin
    name := mapname.Text;
    ShowName := CheckBox11.Checked;
    Loc[1] := StrToInt(up.Text);
    Loc[2] := StrToInt(down.Text);
    Loc[3] := StrToInt(left.Text);
    Loc[4] := StrToInt(right.Text);
  end;
end;

{ Взять инфу из карты }
procedure TMainEdForm.TakeInfo;
begin
  with SpecialMaps[NowMap] do
  begin
    mapname.Text := name;
    CheckBox11.Checked := ShowName;
    up.Text := IntToStr(Loc[1]);
    down.Text := IntToStr(Loc[2]);
    left.Text := IntToStr(Loc[3]);
    right.Text := IntToStr(Loc[4]);
  end;
end;

{ При движении мышки }
procedure TMainEdForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  // Изменить координаты
  CurX := (X div CharX) + 1;
  CurY := (Y div CharY) + 1;
  coord.Caption := IntToStr(CurX) + ':' + IntToStr(CurY);
  if M.MonP[CurX, CurY] > 0 then
    Label3.Caption := IntToStr(M.MonL[M.MonP[CurX, CurY]].id);
  // Рисовать
  if not WaitForLadderClick then
    if (CurX > 0) and (CurX <= MapX) and (CurY > 0) and (CurY <= MapY) then
    begin
      // Поместить (ЛКМ)
      if ssLeft in Shift then
      begin
        // Кровь
        if BloodMode.ItemIndex = 1 then
          M.Blood[CurX, CurY] := Random(2) + 1
        else
          case NowElement of
            1: // Тайл
              M.Tile[CurX, CurY] := ItemsBox.ItemIndex + 1;
            2: // Монстр
              CreateMonster(ItemsBox.ItemIndex + 1, CurX, CurY);
            3: // Предмет
              begin
                PutItem(CurX, CurY, CreateItem(ItemsBox.ItemIndex + 1, 1, 0), 1);
              end;
          end;
      end;
      // Удалить? (ПКМ)
      if ssRight in Shift then
      begin
        // Кровь
        if BloodMode.ItemIndex = 1 then
          M.Blood[CurX, CurY] := 0
        else
          case NowElement of
            1: // Тайл
              begin
                M.Tile[CurX, CurY] := 0;
              end;
            2: // Монстр
              begin
                FillMemory(@M.MonL[M.MonP[CurX, CurY]], SizeOf(M.MonL[M.MonP[CurX, CurY]]), 0);
                M.MonP[CurX, CurY] := 0;
              end;
            3: // Предмет
              begin
                M.Item[CurX, CurY].id := 0;
              end;
          end;
      end;
    end;
  // Обновить
  OnPaint(Sender);
end;

{ При нажатии кнопки на мышки }
procedure TMainEdForm.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: byte;
begin
  // Рисовать
  if (CurX > 0) and (CurX <= MapX) and (CurY > 0) and (CurY <= MapY) then
  begin
    // Поместить (ЛКМ)
    if ssLeft in Shift then
    begin
      // Зайти в свойства монстра
      if WaitForMonsterClick then
      begin
        if M.MonP[CurX, CurY] > 0 then
        begin
          // Открыть окно свойств
          with GroupBox8 do
          begin
            GroupBox2.Visible := False;
            Visible := TRUE;
            relation.ItemIndex := M.MonL[M.MonP[CurX, CurY]].relation;
            Label4.Caption := IntToStr(CurX);
            Label5.Caption := IntToStr(CurY);
          end;
        end
        else
          WaitForMonsterClick := False;
      end
      else
        // Сделать тайл лестницой или просто зайти в ее конфигурацию
        if WaitForLadderClick then
        begin
          // Свойства лестницы вниз
          if (M.Tile[CurX, CurY] = tdDSTAIRS) or (M.Tile[CurX, CurY] = tdCHATCH) or (M.Tile[CurX, CurY] = tdDUNENTER) then
          begin
            N := 0;
            // Проверка на наличие такой лестницы
            for i := 1 to MaxLadders do
              if (SpecialMaps[NowMap].Ladders[i].X = CurX) and (SpecialMaps[NowMap].Ladders[i].Y = CurY) then
              begin
                N := i;
                break;
              end;
            // Если лестница не найдена - создать
            if N = 0 then
              for i := 1 to MaxLadders do
                if (SpecialMaps[NowMap].Ladders[i].X = 0) and (SpecialMaps[NowMap].Ladders[i].Y = 0) then
                begin
                  SpecialMaps[NowMap].Ladders[i].X := CurX;
                  SpecialMaps[NowMap].Ladders[i].Y := CurY;
                  N := i;
                  break;
                end;
            // Открыть окно свойств
            with GroupBox6 do
            begin
              GroupBox2.Visible := False;
              Visible := TRUE;
              numberchange.Clear;
              numberchange.items.Add('Сменить на:');
              for i := 1 to MaxLadders do
                if (SpecialMaps[NowMap].Ladders[i].X > 0) then
                  numberchange.items.Add(IntToStr(i) + '-' + 'занято')
                else
                  numberchange.items.Add(IntToStr(i) + '-' + 'свободно!');
              numberchange.ItemIndex := 0;
              number.Caption := '№' + IntToStr(N);
              if SpecialMaps[NowMap].Ladders[N].Name = '' then
                RandomName.Checked := TRUE
              else
              begin
                RandomName.Checked := False;
                DungeonName.Enabled := TRUE;
                DungeonName.Text := SpecialMaps[NowMap].Ladders[N].Name;
              end;
              { Забыл как делать поиск компонента, а тот что вспомнил почему-то не работает...
                Короче, сделал тупо :) }
              with pregen1 do
              begin
                items.Clear;
                items.Add('- Рандомная -');
                for i := 1 to MaxMaps do
                  if SpecialMaps[i].Map.Special > 0 then
                    items.Add(IntToStr(i) + ' - ' + SpecialMaps[i].Name);
              end;
              with pregen2 do
              begin
                items.Clear;
                items.Add('- Рандомная -');
                for i := 1 to MaxMaps do
                  if SpecialMaps[i].Map.Special > 0 then
                    items.Add(IntToStr(i) + ' - ' + SpecialMaps[i].Name);
              end;
              with pregen3 do
              begin
                items.Clear;
                items.Add('- Рандомная -');
                for i := 1 to MaxMaps do
                  if SpecialMaps[i].Map.Special > 0 then
                    items.Add(IntToStr(i) + ' - ' + SpecialMaps[i].Name);
              end;
              with pregen4 do
              begin
                items.Clear;
                items.Add('- Рандомная -');
                for i := 1 to MaxMaps do
                  if SpecialMaps[i].Map.Special > 0 then
                    items.Add(IntToStr(i) + ' - ' + SpecialMaps[i].Name);
              end;
              with pregen5 do
              begin
                items.Clear;
                items.Add('- Рандомная -');
                for i := 1 to MaxMaps do
                  if SpecialMaps[i].Map.Special > 0 then
                    items.Add(IntToStr(i) + ' - ' + SpecialMaps[i].Name);
              end;
              with pregen6 do
              begin
                items.Clear;
                items.Add('- Рандомная -');
                for i := 1 to MaxMaps do
                  if SpecialMaps[i].Map.Special > 0 then
                    items.Add(IntToStr(i) + ' - ' + SpecialMaps[i].Name);
              end;
              with pregen7 do
              begin
                items.Clear;
                items.Add('- Рандомная -');
                for i := 1 to MaxMaps do
                  if SpecialMaps[i].Map.Special > 0 then
                    items.Add(IntToStr(i) + ' - ' + SpecialMaps[i].Name);
              end;
              with pregen8 do
              begin
                items.Clear;
                items.Add('- Рандомная -');
                for i := 1 to MaxMaps do
                  if SpecialMaps[i].Map.Special > 0 then
                    items.Add(IntToStr(i) + ' - ' + SpecialMaps[i].Name);
              end;
              with pregen9 do
              begin
                items.Clear;
                items.Add('- Рандомная -');
                for i := 1 to MaxMaps do
                  if SpecialMaps[i].Map.Special > 0 then
                    items.Add(IntToStr(i) + ' - ' + SpecialMaps[i].Name);
              end;
              with pregen10 do
              begin
                items.Clear;
                items.Add('- Рандомная -');
                for i := 1 to MaxMaps do
                  if SpecialMaps[i].Map.Special > 0 then
                    items.Add(IntToStr(i) + ' - ' + SpecialMaps[i].Name);
              end;
              //
              CheckBox1.Checked := SpecialMaps[NowMap].Ladders[N].Levels[1].IsHere;
              pregen1.ItemIndex := SpecialMaps[NowMap].Ladders[N].Levels[1].PregenLevel;
              cool1.Text := IntToStr(SpecialMaps[NowMap].Ladders[N].Levels[1].CoolLevel);
              type1.Text := IntToStr(SpecialMaps[NowMap].Ladders[N].Levels[1].DungeonType);
              //
              CheckBox2.Checked := SpecialMaps[NowMap].Ladders[N].Levels[2].IsHere;
              pregen2.ItemIndex := SpecialMaps[NowMap].Ladders[N].Levels[2].PregenLevel;
              cool2.Text := IntToStr(SpecialMaps[NowMap].Ladders[N].Levels[2].CoolLevel);
              type2.Text := IntToStr(SpecialMaps[NowMap].Ladders[N].Levels[2].DungeonType);
              //
              CheckBox3.Checked := SpecialMaps[NowMap].Ladders[N].Levels[3].IsHere;
              pregen3.ItemIndex := SpecialMaps[NowMap].Ladders[N].Levels[3].PregenLevel;
              cool3.Text := IntToStr(SpecialMaps[NowMap].Ladders[N].Levels[3].CoolLevel);
              type3.Text := IntToStr(SpecialMaps[NowMap].Ladders[N].Levels[3].DungeonType);
              //
              CheckBox4.Checked := SpecialMaps[NowMap].Ladders[N].Levels[4].IsHere;
              pregen4.ItemIndex := SpecialMaps[NowMap].Ladders[N].Levels[4].PregenLevel;
              cool4.Text := IntToStr(SpecialMaps[NowMap].Ladders[N].Levels[4].CoolLevel);
              type4.Text := IntToStr(SpecialMaps[NowMap].Ladders[N].Levels[4].DungeonType);
              //
              CheckBox5.Checked := SpecialMaps[NowMap].Ladders[N].Levels[5].IsHere;
              pregen5.ItemIndex := SpecialMaps[NowMap].Ladders[N].Levels[5].PregenLevel;
              cool5.Text := IntToStr(SpecialMaps[NowMap].Ladders[N].Levels[5].CoolLevel);
              type5.Text := IntToStr(SpecialMaps[NowMap].Ladders[N].Levels[5].DungeonType);
              //
              CheckBox6.Checked := SpecialMaps[NowMap].Ladders[N].Levels[6].IsHere;
              pregen6.ItemIndex := SpecialMaps[NowMap].Ladders[N].Levels[6].PregenLevel;
              cool6.Text := IntToStr(SpecialMaps[NowMap].Ladders[N].Levels[6].CoolLevel);
              type6.Text := IntToStr(SpecialMaps[NowMap].Ladders[N].Levels[6].DungeonType);
              //
              CheckBox7.Checked := SpecialMaps[NowMap].Ladders[N].Levels[7].IsHere;
              pregen7.ItemIndex := SpecialMaps[NowMap].Ladders[N].Levels[7].PregenLevel;
              cool7.Text := IntToStr(SpecialMaps[NowMap].Ladders[N].Levels[7].CoolLevel);
              type7.Text := IntToStr(SpecialMaps[NowMap].Ladders[N].Levels[7].DungeonType);
              //
              CheckBox8.Checked := SpecialMaps[NowMap].Ladders[N].Levels[8].IsHere;
              pregen8.ItemIndex := SpecialMaps[NowMap].Ladders[N].Levels[8].PregenLevel;
              cool8.Text := IntToStr(SpecialMaps[NowMap].Ladders[N].Levels[8].CoolLevel);
              type8.Text := IntToStr(SpecialMaps[NowMap].Ladders[N].Levels[8].DungeonType);
              //
              CheckBox9.Checked := SpecialMaps[NowMap].Ladders[N].Levels[9].IsHere;
              pregen9.ItemIndex := SpecialMaps[NowMap].Ladders[N].Levels[9].PregenLevel;
              cool9.Text := IntToStr(SpecialMaps[NowMap].Ladders[N].Levels[9].CoolLevel);
              type9.Text := IntToStr(SpecialMaps[NowMap].Ladders[N].Levels[9].DungeonType);
              //
              CheckBox10.Checked := SpecialMaps[NowMap].Ladders[N].Levels[10].IsHere;
              pregen10.ItemIndex := SpecialMaps[NowMap].Ladders[N].Levels[10].PregenLevel;
              cool10.Text := IntToStr(SpecialMaps[NowMap].Ladders[N].Levels[10].CoolLevel);
              type10.Text := IntToStr(SpecialMaps[NowMap].Ladders[N].Levels[10].DungeonType);
            end;
          end
          else
            // Свойства лестницы вверх
            if M.Tile[CurX, CurY] = tdUSTAIRS then
            begin
              // Открыть окно свойств
              with GroupBox7 do
              begin
                GroupBox2.Visible := False;
                Visible := TRUE;
                with Pregen do
                begin
                  ItemIndex := 0;
                  items.Clear;
                  items.Add('- Рандомная -');
                  for i := 1 to MaxMaps do
                    if SpecialMaps[i].Map.Special > 0 then
                      items.Add(IntToStr(i) + ' - ' + SpecialMaps[i].Name);
                  ItemIndex := SpecialMaps[NowMap].LadderUp;
                end;
              end;
            end;
        end
        else
          // Кровь
          if BloodMode.ItemIndex = 1 then
            M.Blood[CurX, CurY] := Random(2) + 1
          else
            // Тайл монстр
            case NowElement of
              1: // Тайл
                M.Tile[CurX, CurY] := ItemsBox.ItemIndex + 1;
              2: // Монстр
                CreateMonster(ItemsBox.ItemIndex + 1, CurX, CurY);
              3: // Предмет
                begin
                  PutItem(CurX, CurY, CreateItem(ItemsBox.ItemIndex + 1, 1, 0), 1);
                end;
            end;
    end;
    // Удалить? (ПКМ)
    if ssRight in Shift then
    begin
      // Кровь
      if BloodMode.ItemIndex = 1 then
        M.Blood[CurX, CurY] := 0
      else
        case NowElement of
          1: // Тайл
            M.Tile[CurX, CurY] := 0;
          2: // Монстр
            begin
              FillMemory(@M.MonL[M.MonP[CurX, CurY]], SizeOf(M.MonL[M.MonP[CurX, CurY]]), 0);
              M.MonP[CurX, CurY] := 0;
            end;
          3: // Предмет
            begin
              M.Item[CurX, CurY].id := 0;
            end;
        end;
    end;
  end;
  // Обновить
  OnPaint(Sender)
end;

{ Обновить список элементов }
procedure TMainEdForm.RefreshItemList;
var
  i: Integer;
begin
  case NowElement of
    1: // Тайлы
      begin
        GroupBox1.Caption := 'Тайлы';
        ItemsBox.items.Clear;
        for i := 1 to LevelTilesAmount do
          ItemsBox.items.Add(TilesData[i].Name);

      end;
    2: // Монстры
      begin
        GroupBox1.Caption := 'Монстры';
        ItemsBox.items.Clear;
        for i := 1 to MonstersAmount do
          ItemsBox.items.Add(MonstersData[i].name1);
      end;
    3: // Предметы
      begin
        GroupBox1.Caption := 'Предметы';
        ItemsBox.items.Clear;
        for i := 1 to ItemsAmount do
          ItemsBox.items.Add(ItemsData[i].name1);
      end;
  end;
  if (NowElement = 1) then
    SetTiles.Font.Style := [fsBold]
  else
    SetTiles.Font.Style := [];
  if (NowElement = 2) then
    SetMonsters.Font.Style := [fsBold]
  else
    SetMonsters.Font.Style := [];
  if (NowElement = 3) then
    SetItems.Font.Style := [fsBold]
  else
    SetItems.Font.Style := [];
end;

{ Выбрал тайлы }
procedure TMainEdForm.SetTilesClick(Sender: TObject);
begin
  NowElement := 1;
  RefreshItemList;
end;

{ Выбрал монстров }
procedure TMainEdForm.SetMonstersClick(Sender: TObject);
begin
  NowElement := 2;
  RefreshItemList;
end;

procedure TMainEdForm.SetItemsClick(Sender: TObject);
begin
  NowElement := 3;
  RefreshItemList;
end;

{ Список карт }
procedure TMainEdForm.RefreshMapList;
var
  i: byte;
begin
  MapList.items.Clear;
  for i := 1 to MaxMaps do
    if SpecialMaps[i].Map.Special > 0 then
    begin
      if SpecialMaps[i].Map.Special <> i then
        SpecialMaps[i].Map.Special := i;
      MapList.items.Add(IntToStr(SpecialMaps[i].Map.Special) + ' - ' + SpecialMaps[i].Name);
    end;
  MapList.items.Add('-- Создать новую --');
  MapList.ItemIndex := NowMap - 1;
end;

procedure TMainEdForm.N2Click(Sender: TObject);
var
  X, Y, i: byte;
  h: boolean;
begin
  SaveSpecialMaps;
  // Проверка
  for i := 1 to MaxMaps do
    if SpecialMaps[i].Map.Special > 0 then
    begin
      h := False;
      for X := 1 to MapX do
        for Y := 1 to MapY do
          If SpecialMaps[i].Map.Tile[X, Y] = tdUSTAIRS then
            h := TRUE;
      if (h) and (SpecialMaps[i].LadderUp = 0) then
        MsgBox('В локации "' + SpecialMaps[i].Name + '" не определены свойства лестницы вверх!');
    end;
end;

procedure TMainEdForm.N3Click(Sender: TObject);
begin
  LoadSpecialMaps;
  RefreshMapList;
  NowMap := 1;
  M := SpecialMaps[NowMap].Map;
  TakeInfo;
  OnPaint(Sender);
end;

procedure TMainEdForm.Button6Click(Sender: TObject);
begin
  if NowMap = 0 then
    MsgBox('Для начала необходимо выбрать карту!')
  else
    WaitForLadderClick := TRUE;
end;

{ Применить изменения в свойствах лестницы }
procedure TMainEdForm.Button7Click(Sender: TObject);
begin
  WaitForLadderClick := False;
  with GroupBox6 do
  begin
    if (RandomName.Checked) or (DungeonName.Text = '') then
      SpecialMaps[NowMap].Ladders[N].Name := ''
    else
      SpecialMaps[NowMap].Ladders[N].Name := DungeonName.Text;
    //
    SpecialMaps[NowMap].Ladders[N].Levels[1].IsHere := CheckBox1.Checked;
    SpecialMaps[NowMap].Ladders[N].Levels[1].PregenLevel := pregen1.ItemIndex;
    SpecialMaps[NowMap].Ladders[N].Levels[1].CoolLevel := StrToInt(cool1.Text);
    SpecialMaps[NowMap].Ladders[N].Levels[1].DungeonType := StrToInt(type1.Text);
    //
    SpecialMaps[NowMap].Ladders[N].Levels[2].IsHere := CheckBox2.Checked;
    SpecialMaps[NowMap].Ladders[N].Levels[2].PregenLevel := pregen2.ItemIndex;
    SpecialMaps[NowMap].Ladders[N].Levels[2].CoolLevel := StrToInt(cool2.Text);
    SpecialMaps[NowMap].Ladders[N].Levels[2].DungeonType := StrToInt(type2.Text);
    //
    SpecialMaps[NowMap].Ladders[N].Levels[3].IsHere := CheckBox3.Checked;
    SpecialMaps[NowMap].Ladders[N].Levels[3].PregenLevel := pregen3.ItemIndex;
    SpecialMaps[NowMap].Ladders[N].Levels[3].CoolLevel := StrToInt(cool3.Text);
    SpecialMaps[NowMap].Ladders[N].Levels[3].DungeonType := StrToInt(type3.Text);
    //
    SpecialMaps[NowMap].Ladders[N].Levels[4].IsHere := CheckBox4.Checked;
    SpecialMaps[NowMap].Ladders[N].Levels[4].PregenLevel := pregen4.ItemIndex;
    SpecialMaps[NowMap].Ladders[N].Levels[4].CoolLevel := StrToInt(cool4.Text);
    SpecialMaps[NowMap].Ladders[N].Levels[4].DungeonType := StrToInt(type4.Text);
    //
    SpecialMaps[NowMap].Ladders[N].Levels[5].IsHere := CheckBox5.Checked;
    SpecialMaps[NowMap].Ladders[N].Levels[5].PregenLevel := pregen5.ItemIndex;
    SpecialMaps[NowMap].Ladders[N].Levels[5].CoolLevel := StrToInt(cool5.Text);
    SpecialMaps[NowMap].Ladders[N].Levels[5].DungeonType := StrToInt(type5.Text);
    //
    SpecialMaps[NowMap].Ladders[N].Levels[6].IsHere := CheckBox6.Checked;
    SpecialMaps[NowMap].Ladders[N].Levels[6].PregenLevel := pregen6.ItemIndex;
    SpecialMaps[NowMap].Ladders[N].Levels[6].CoolLevel := StrToInt(cool6.Text);
    SpecialMaps[NowMap].Ladders[N].Levels[6].DungeonType := StrToInt(type6.Text);
    //
    SpecialMaps[NowMap].Ladders[N].Levels[7].IsHere := CheckBox7.Checked;
    SpecialMaps[NowMap].Ladders[N].Levels[7].PregenLevel := pregen7.ItemIndex;
    SpecialMaps[NowMap].Ladders[N].Levels[7].CoolLevel := StrToInt(cool7.Text);
    SpecialMaps[NowMap].Ladders[N].Levels[7].DungeonType := StrToInt(type7.Text);
    //
    SpecialMaps[NowMap].Ladders[N].Levels[8].IsHere := CheckBox8.Checked;
    SpecialMaps[NowMap].Ladders[N].Levels[8].PregenLevel := pregen8.ItemIndex;
    SpecialMaps[NowMap].Ladders[N].Levels[8].CoolLevel := StrToInt(cool8.Text);
    SpecialMaps[NowMap].Ladders[N].Levels[8].DungeonType := StrToInt(type8.Text);
    //
    SpecialMaps[NowMap].Ladders[N].Levels[9].IsHere := CheckBox9.Checked;
    SpecialMaps[NowMap].Ladders[N].Levels[9].PregenLevel := pregen9.ItemIndex;
    SpecialMaps[NowMap].Ladders[N].Levels[9].CoolLevel := StrToInt(cool9.Text);
    SpecialMaps[NowMap].Ladders[N].Levels[9].DungeonType := StrToInt(type9.Text);
    //
    SpecialMaps[NowMap].Ladders[N].Levels[10].IsHere := CheckBox10.Checked;
    SpecialMaps[NowMap].Ladders[N].Levels[10].PregenLevel := pregen10.ItemIndex;
    SpecialMaps[NowMap].Ladders[N].Levels[10].CoolLevel := StrToInt(cool10.Text);
    SpecialMaps[NowMap].Ladders[N].Levels[10].DungeonType := StrToInt(type10.Text);
    //
    if numberchange.ItemIndex > 0 then
      if SpecialMaps[NowMap].Ladders[numberchange.ItemIndex].X = 0 then
      begin
        SpecialMaps[NowMap].Ladders[numberchange.ItemIndex] := SpecialMaps[NowMap].Ladders[N];
        FillMemory(@SpecialMaps[NowMap].Ladders[N], SizeOf(SpecialMaps[NowMap].Ladders[N]), 0);
      end;
    Visible := False;
    GroupBox2.Visible := TRUE;
  end;
end;

procedure TMainEdForm.Button1Click(Sender: TObject);
begin
  WaitForLadderClick := False;
  with GroupBox7 do
  begin
    SpecialMaps[NowMap].LadderUp := Pregen.ItemIndex;
    Visible := False;
  end;
  GroupBox2.Visible := TRUE;
end;

procedure TMainEdForm.ListBox1Click(Sender: TObject);
begin
  OnPaint(Sender);
end;

procedure TMainEdForm.SpeedButton1Click(Sender: TObject);
var
  i, X, Y: byte;
begin
  for X := 1 to MapX do
    for Y := 1 to MapY do
      M.MonP[X, Y] := 0;
  for i := 1 to 255 do
    FillMemory(@M.MonL[i], SizeOf(M.MonL[i]), 0);
end;

procedure TMainEdForm.Button2Click(Sender: TObject);
begin
  if NowMap = 0 then
    MsgBox('Для начала необходимо выбрать карту!')
  else
    WaitForMonsterClick := TRUE;
end;

{ Свойства монстра }
procedure TMainEdForm.Button3Click(Sender: TObject);
begin
  WaitForMonsterClick := False;
  with GroupBox8 do
  begin
    M.MonL[M.MonP[StrToInt(Label4.Caption), StrToInt(Label5.Caption)]].relation := relation.ItemIndex;
    Visible := False;
  end;
  GroupBox2.Visible := TRUE;
end;

// Обновить лестницы, удалить несуществующие
procedure TMainEdForm.SpeedButton2Click(Sender: TObject);
var
  i: byte;
begin
  for i := 1 to MaxLadders do
    with SpecialMaps[NowMap].Ladders[i] do
    begin
      if (M.Tile[X, Y] <> tdDSTAIRS) and (M.Tile[X, Y] <> tdCHATCH) and (M.Tile[X, Y] <> tdDUNENTER) then
      begin
        X := 0;
        Y := 0;
      end;
    end;
end;

procedure TMainEdForm.RandomNameClick(Sender: TObject);
begin
  if RandomName.Checked then
    DungeonName.Enabled := False
  else
    DungeonName.Enabled := TRUE;
end;

procedure TMainEdForm.Timer1Timer(Sender: TObject);
begin
  FormPaint(Sender);
end;

procedure TMainEdForm.N5Click(Sender: TObject);
begin
  Close
end;

end.
