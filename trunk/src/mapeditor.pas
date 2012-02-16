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
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FillClick(Sender: TObject);
    procedure DrawMap;
    procedure SaveClick(Sender: TObject);
    procedure MapListClick(Sender: TObject);
    function LoadSpecialMaps : boolean;
    function SaveSpecialMaps : boolean;
    procedure AddInfo;
    procedure TakeInfo;
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure RefreshItemList;
    procedure SetTilesClick(Sender: TObject);
    procedure SetMonstersClick(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
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
  private
  public
  end;

const
  MaxMaps = 255;

type
  TLevel = record
    IsHere      : boolean; // Нужен ли здесь уровень вообще
    PregenLevel : byte;    // Если > 0, значит это спец. уровень и вся остальная инфа не нужна
    CoolLevel   : byte;    // Уровень крутости
    DungeonType : byte;    // Тип генерируемого уровня
    Reserv      : array[1..20] of byte; // Резерв
  end;

  TLadder = record
    name   : string[17];                    // Название подзмелья
    x, y   : byte;                          // Расположение лестницы
    Levels : array[1..MaxDepth] of TLevel;  // Характеристики каждого уровня
  end;

  TMaps = record
    name : string[40];         // Название карты
    ShowName : boolean;                         // Отображать название спец. карты
    Map : TMap;                // Сама карта
    Loc : array[1..4] of byte; // Окружающие ее карты (1-Вверх,2-Вниз,3-Влево,4-Вправо)
    Ladders : array[1..MaxLadders] of TLadder;  // Свойства лестниц вниз
    LadderUp : byte;           // Куда ведет лестница вверх
  end;

var
  MainEdForm: TMainEdForm;
  EdScreen : TBitMap;
  SpecialMaps : array[1..MaxMaps] of TMaps;
  NowMap, NowElement, N : byte;
  CurX, CurY : integer;
  WaitForLadderClick,
  WaitForMonsterClick : boolean;
  NowLadder : byte;

implementation

{$R *.dfm}

uses
  Tile, Player, Utils, Monsters, conf, mbox;

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
  EdScreen := TBitMap.Create;
  EdScreen.Width := MapX * CharX;
  EdScreen.Height := MapY * CharY;
  EdScreen.Canvas.Font.Name := FontMsg;
  // Компоненты
  GroupBox2.Top := 0;
  GroupBox2.Left := MapX * CharX + 10;
  GroupBox6.Left := GroupBox2.Left;
  GroupBox7.Left := GroupBox2.Left;
  GroupBox8.Left := GroupBox2.Left;

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
  x, y : byte;
begin
  if NowElement = 1 then
  begin
    for x:=1 to MapX do
      for y:=1 to MapY do
        M.Tile[x,y] := ItemsBox.ItemIndex + 1;
    OnPaint(Sender);
  end;
end;

{ Вывести карту }
procedure TMainEdForm.DrawMap;
var
  x, y    : integer;
  color,back      : longword;
  char       : string[1];
begin
  for x:=1 to MapX do
    for y:=1 to MapY do
      with EdScreen.Canvas do
      begin
        color := 255;
        back := 0;
        Brush.Color := 0;
        // Тайл
        case M.Blood[x,y] of
          0 : color := RealColor(TilesData[M.Tile[x,y]].color);
          1 : color := cLIGHTRED;
          2 : color := cRED;
        end;
        char := TilesData[M.Tile[x,y]].char;
        back := Darker(RealColor(TilesData[M.Tile[x,y]].color), 92);
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
                color := RealColor(MonstersData[M.MonL[M.MonP[x,y]].id].color);
                if M.MonL[M.MonP[x,y]].felldown then color:= cGRAY;
                if M.MonP[x,y] = ListBox1.ItemIndex+1 then
                  back := MyRGB(150,0,0);
                char := MonstersData[M.MonL[M.MonP[x,y]].id].char;
              end;
        end;
        // Вывести символ
        Brush.Color := back;
        Font.Color := color;
        TextOut((x-1)*CharX, (y-1)*CharY, char);
      end;
end;

{ Перезаписать }
procedure TMainEdForm.Button5Click(Sender: TObject);
begin
  if NowMap = 0 then
    MsgBox('Не выбрана карта!') else
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
  i : byte;
begin
  for i:=1 to MaxMaps do
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
  i : byte;
begin
  NowMap := MapList.ItemIndex+1;
  M.Clear;
  M := SpecialMaps[NowMap].Map;
  TakeInfo;
  OnPaint(Sender);
  ListBox1.Clear;
  for i:=1 to 255 do
    ListBox1.Items.Add(IntToStr(i) +' - '+IntToStr(M.MonL[i].id));
end;

{ Загрузить карты }
function TMainEdForm.LoadSpecialMaps : boolean;
var
  f : file;
  i,kol,m,k,x,y,z : byte;
begin
  Result := FALSE;
  AssignFile(f,'data/maps.dm');
  {$I-}
  Reset(f,1);
  {$I+}
  if IOResult = 0 then
  begin
    Result := TRUE;
    BlockRead(f, kol, SizeOf(kol));
    for i:=1 to kol do
    begin
      // Номер и название карты
      BlockRead(f, SpecialMaps[i].Map.Special, SizeOf(SpecialMaps[i].Map.Special));
      BlockRead(f, SpecialMaps[i].name, SizeOf(SpecialMaps[i].name));
      BlockRead(f, SpecialMaps[i].ShowName, SizeOf(SpecialMaps[i].ShowName));
      // Карта - тайлы, кровь, монстры, предметы
      BlockRead(f, SpecialMaps[i].map.Tile, SizeOf(SpecialMaps[i].map.Tile));
      BlockRead(f, SpecialMaps[i].map.Blood, SizeOf(SpecialMaps[i].map.Blood));
      // Лестницы
      BlockRead(f, SpecialMaps[i].Ladders, SizeOf(SpecialMaps[i].Ladders));
      BlockRead(f, SpecialMaps[i].LadderUp, SizeOf(SpecialMaps[i].LadderUp));
      // Соседние локации
      BlockRead(f, SpecialMaps[i].Loc, SizeOf(SpecialMaps[i].Loc));
    end;
    CloseFile(f);
  end;
  // Монстры
  AssignFile(f,'data/monsters.dm');
  {$I-}
  Reset(f,1);
  {$I+}
  if IOResult = 0 then
  begin
    if Result = TRUE then Result := TRUE;
    for i:=1 to kol do
    begin
      // Читаем кол-во монстров
      BlockRead(f, k, SizeOf(k));
      BlockRead(f, SpecialMaps[i].map.MonP, SizeOf(SpecialMaps[i].map.MonP));
      if k > 0 then
        for m:=1 to k do
          with SpecialMaps[i].map.MonL[m] do
          begin
            BlockRead(f, id, SizeOf(id));
            BlockRead(f, relation, SizeOf(relation));
          end;
    end;
    CloseFile(f);
  end else
    Result := FALSE;
  // Предметы
  AssignFile(f,'data/items.dm');
  {$I-}
  Reset(f,1);
  {$I+}
  if IOResult = 0 then
  begin
    if Result = TRUE then Result := TRUE;
    for i:=1 to kol do
    begin
      z := 0;
      for x:=1 to MapX do
        for y:=1 to MapY do
        begin
          BlockRead(f, z ,1);
          if z > 0 then
            BlockRead(f, SpecialMaps[i].map.Item, SizeOf(SpecialMaps[i].map.Item));
        end;
    end;
    CloseFile(f);
  end else
    Result := FALSE;
end;

{ Сохранить карты }
function TMainEdForm.SaveSpecialMaps : boolean;
var
  f : file;
  i,kol,m,k,x,y,z,b : byte;
begin
  CreateDir('data');
  // Локации
  AssignFile(f,'data/maps.dm');
  {$I-}
  Rewrite(f,1);
  for kol:=1 to MaxMaps do
    if SpecialMaps[kol].Map.Special = 0 then
      break;
  kol := kol - 1;
  BlockWrite(f, kol, SizeOf(kol));
  if kol > 0 then
    for i:=1 to kol do
    begin
      // Номер и название карты
      BlockWrite(f, SpecialMaps[i].Map.Special, SizeOf(SpecialMaps[i].Map.Special));
      BlockWrite(f, SpecialMaps[i].name, SizeOf(SpecialMaps[i].name));
      BlockWrite(f, SpecialMaps[i].ShowName, SizeOf(SpecialMaps[i].ShowName));
      // Карта - тайлы, кровь, монстры, предметы
      BlockWrite(f, SpecialMaps[i].map.Tile, SizeOf(SpecialMaps[i].map.Tile));
      BlockWrite(f, SpecialMaps[i].map.Blood, SizeOf(SpecialMaps[i].map.Blood));
      // Лестницы
      BlockWrite(f, SpecialMaps[i].Ladders, SizeOf(SpecialMaps[i].Ladders));
      BlockWrite(f, SpecialMaps[i].LadderUp, SizeOf(SpecialMaps[i].LadderUp));
      // Соседние локации
      BlockWrite(f, SpecialMaps[i].Loc, SizeOf(SpecialMaps[i].Loc));
    end;
  CloseFile(f);
  {$I+}
  if IOResult <> 0 then
    Result := false else
      Result := true;
  // Монстры
  AssignFile(f,'data/monsters.dm');
  {$I-}
  Rewrite(f,1);
  if kol > 0 then
    for i:=1 to kol do
    begin
      // Определяем кол-во монстров
      for k:=2 to 255 do
        if SpecialMaps[i].map.MonL[k].id = 0 then
          break;
      k := k - 1;
      BlockWrite(f, k, SizeOf(k));
      BlockWrite(f, SpecialMaps[i].map.MonP, SizeOf(SpecialMaps[i].map.MonP));
      // Монстров записываем поочереди
      if k > 0 then
        for m:=1 to k do
        begin
          with SpecialMaps[i].map.MonL[m] do
          begin
            BlockWrite(f, id, SizeOf(id));
            BlockWrite(f, relation, SizeOf(relation));
          end;
        end;
    end;
  CloseFile(f);
  {$I+}
  if IOResult <> 0 then
    Result := false else
      Result := true;
  // Предметы
  AssignFile(f,'data/items.dm');
  {$I-}
  Rewrite(f,1);
  if kol > 0 then
    for i:=1 to kol do
    begin
      z := 0;
      for x:=1 to MapX do
        for y:=1 to MapY do
          if SpecialMaps[i].map.Item[x,y].id = 0 then
            BlockWrite(f, z, 1) else
              BlockWrite(f, SpecialMaps[i].map.Item, SizeOf(SpecialMaps[i].map.Item));
    end;
  CloseFile(f);
  {$I+}
  if IOResult <> 0 then
    Result := false else
      Result := true;
end;

{ Добавить инфу в текущую карту }
procedure TMainEdForm.AddInfo;
begin
  with SpecialMaps[NowMap] do
  begin
    name := mapname.Text;
    ShowName := CheckBox11.Checked;
    loc[1] := StrToInt(up.Text);
    loc[2] := StrToInt(down.Text);
    loc[3] := StrToInt(left.Text);
    loc[4] := StrToInt(right.Text);
  end;
end;

{ Взять инфу из карты }
procedure TMainEdForm.TakeInfo;
begin
  with SpecialMaps[NowMap] do
  begin
    mapname.Text := name;
    CheckBox11.Checked := ShowName;
    up.Text := IntToStr(loc[1]);
    down.Text := IntToStr(loc[2]);
    left.Text := IntToStr(loc[3]);
    right.Text := IntToStr(loc[4]);
  end;
end;

{ При движении мышки }
procedure TMainEdForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  // Изменить координаты
  CurX := (X div 8) + 1;
  CurY := (Y div 16) + 1;
  coord.Caption := IntToStr(CurX)+':'+IntToStr(CurY);
  if M.MonP[CurX, CurY] > 0 then
    Label3.Caption := IntToStr(M.MonL[M.MonP[CurX, CurY]].id);
  // Рисовать
  if not WaitForLadderClick  then
    if (CurX > 0) and (CurX <= MapX) and (CurY > 0) and (CurY <= MapY) then
    begin
      // Поместить (ЛКМ)
      if ssLeft in Shift then
      begin
        // Кровь
        if BloodMode.ItemIndex = 1 then
          M.Blood[CurX, CurY] := Random(2)+1 else
            case NowElement of
              1 : //Тайл
              M.Tile[CurX, CurY] := ItemsBox.ItemIndex+1;
              2 : //Монстр
              CreateMonster(ItemsBox.ItemIndex+1,CurX,CurY);
            end;
      end;
      // Удалить? (ПКМ)
      if ssRight in Shift then
      begin
        // Кровь
        if BloodMode.ItemIndex = 1 then
          M.Blood[CurX, CurY] := 0 else
            case NowElement of
              1 : //Тайл
              M.Tile[CurX, CurY] := 0;
              2 : //Монстр
              begin
                FillMemory(@M.MonL[M.MonP[CurX, CurY]], SizeOf(M.MonL[M.MonP[CurX, CurY]]), 0);
                M.MonP[CurX, CurY] := 0;
              end;
            end;
      end;
    end;
    // Обновить
  OnPaint(Sender);
end;

{ При нажатии кнопки на мышки }
procedure TMainEdForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i : byte;
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
            Visible := True;
            relation.ItemIndex := M.MonL[M.MonP[CurX, CurY]].relation;
            label4.Caption := IntToStr(CurX);
            label5.Caption := IntToStr(CurY);
          end;
        end else
          WaitForMonsterClick := False;
      end else
      // Сделать тайл лестницой или просто зайти в ее конфигурацию
      if WaitForLadderClick then
      begin
        // Свойства лестницы вниз
        if (M.Tile[CurX, CurY] = tdDSTAIRS) or (M.Tile[CurX, CurY] = tdCHATCH) or
           (M.Tile[CurX, CurY] = tdDUNENTER) then
        begin
          n := 0;
          // Проверка на наличие такой лестницы
          for i:=1 to MaxLadders do
            if (SpecialMaps[NowMap].Ladders[i].x = CurX) and (SpecialMaps[NowMap].Ladders[i].y = CurY) then
            begin
              n := i;
              break;
            end;
          // Если лестница не найдена - создать
          if n = 0 then
            for i:=1 to MaxLadders do
              if (SpecialMaps[NowMap].Ladders[i].x = 0) and (SpecialMaps[NowMap].Ladders[i].y = 0) then
              begin
                SpecialMaps[NowMap].Ladders[i].x := CurX;
                SpecialMaps[NowMap].Ladders[i].y := CurY;
                n := i;
                break;
              end;
          // Открыть окно свойств
          with GroupBox6 do
          begin
            GroupBox2.Visible := False;
            Visible := True;
            NumberChange.Clear;
            NumberChange.Items.Add('Сменить на:');
            for i:=1 to MaxLadders do
              if (SpecialMaps[NowMap].Ladders[i].x > 0) then
                NumberChange.Items.Add(IntToStr(i) + '-' + 'занято') else
                  NumberChange.Items.Add(IntToStr(i) + '-' + 'свободно!');
            NumberChange.ItemIndex := 0;
            Number.Caption := '№'+IntToStr(n);
            if SpecialMaps[NowMap].Ladders[n].name = '' then
              RandomName.Checked := TRUE else
                begin
                  RandomName.Checked := FALSE;
                  DungeonName.Enabled := TRUE;
                  DungeonName.Text := SpecialMaps[NowMap].Ladders[n].name;
                end;
            { Забыл как делать поиск компонента, а тот что вспомнил почему-то не работает...
                                                                         Короче, сделал тупо :)}
            with Pregen1 do
            begin
              Items.Clear;
              Items.Add('- Рандомная -');
              for i:=1 to MaxMaps do
                if SpecialMaps[i].Map.Special > 0 then
                  Items.Add(IntToStr(i) + ' - '+SpecialMaps[i].name);
            end;
            with Pregen2 do
            begin
              Items.Clear;
              Items.Add('- Рандомная -');
              for i:=1 to MaxMaps do
                if SpecialMaps[i].Map.Special > 0 then
                  Items.Add(IntToStr(i) + ' - '+SpecialMaps[i].name);
            end;
            with Pregen3 do
            begin
              Items.Clear;
              Items.Add('- Рандомная -');
              for i:=1 to MaxMaps do
                if SpecialMaps[i].Map.Special > 0 then
                  Items.Add(IntToStr(i) + ' - '+SpecialMaps[i].name);
            end;
            with Pregen4 do
            begin
              Items.Clear;
              Items.Add('- Рандомная -');
              for i:=1 to MaxMaps do
                if SpecialMaps[i].Map.Special > 0 then
                  Items.Add(IntToStr(i) + ' - '+SpecialMaps[i].name);
            end;
            with Pregen5 do
            begin
              Items.Clear;
              Items.Add('- Рандомная -');
              for i:=1 to MaxMaps do
                if SpecialMaps[i].Map.Special > 0 then
                  Items.Add(IntToStr(i) + ' - '+SpecialMaps[i].name);
            end;
            with Pregen6 do
            begin
              Items.Clear;
              Items.Add('- Рандомная -');
              for i:=1 to MaxMaps do
                if SpecialMaps[i].Map.Special > 0 then
                  Items.Add(IntToStr(i) + ' - '+SpecialMaps[i].name);
            end;
            with Pregen7 do
            begin
              Items.Clear;
              Items.Add('- Рандомная -');
              for i:=1 to MaxMaps do
                if SpecialMaps[i].Map.Special > 0 then
                  Items.Add(IntToStr(i) + ' - '+SpecialMaps[i].name);
            end;
            with Pregen8 do
            begin
              Items.Clear;
              Items.Add('- Рандомная -');
              for i:=1 to MaxMaps do
                if SpecialMaps[i].Map.Special > 0 then
                  Items.Add(IntToStr(i) + ' - '+SpecialMaps[i].name);
            end;
            with Pregen9 do
            begin
              Items.Clear;
              Items.Add('- Рандомная -');
              for i:=1 to MaxMaps do
                if SpecialMaps[i].Map.Special > 0 then
                  Items.Add(IntToStr(i) + ' - '+SpecialMaps[i].name);
            end;
            with Pregen10 do
            begin
              Items.Clear;
              Items.Add('- Рандомная -');
              for i:=1 to MaxMaps do
                if SpecialMaps[i].Map.Special > 0 then
                  Items.Add(IntToStr(i) + ' - '+SpecialMaps[i].name);
            end;
            //
            CheckBox1.Checked := SpecialMaps[NowMap].Ladders[n].Levels[1].IsHere;
            Pregen1.ItemIndex := SpecialMaps[NowMap].Ladders[n].Levels[1].PregenLevel;
            Cool1.Text := IntToStr(SpecialMaps[NowMap].Ladders[n].Levels[1].CoolLevel);
            Type1.Text := IntToStr(SpecialMaps[NowMap].Ladders[n].Levels[1].DungeonType);
            //
            CheckBox2.Checked := SpecialMaps[NowMap].Ladders[n].Levels[2].IsHere;
            Pregen2.ItemIndex := SpecialMaps[NowMap].Ladders[n].Levels[2].PregenLevel;
            Cool2.Text := IntToStr(SpecialMaps[NowMap].Ladders[n].Levels[2].CoolLevel);
            Type2.Text := IntToStr(SpecialMaps[NowMap].Ladders[n].Levels[2].DungeonType);
            //
            CheckBox3.Checked := SpecialMaps[NowMap].Ladders[n].Levels[3].IsHere;
            Pregen3.ItemIndex := SpecialMaps[NowMap].Ladders[n].Levels[3].PregenLevel;
            Cool3.Text := IntToStr(SpecialMaps[NowMap].Ladders[n].Levels[3].CoolLevel);
            Type3.Text := IntToStr(SpecialMaps[NowMap].Ladders[n].Levels[3].DungeonType);
            //
            CheckBox4.Checked := SpecialMaps[NowMap].Ladders[n].Levels[4].IsHere;
            Pregen4.ItemIndex := SpecialMaps[NowMap].Ladders[n].Levels[4].PregenLevel;
            Cool4.Text := IntToStr(SpecialMaps[NowMap].Ladders[n].Levels[4].CoolLevel);
            Type4.Text := IntToStr(SpecialMaps[NowMap].Ladders[n].Levels[4].DungeonType);
            //
            CheckBox5.Checked := SpecialMaps[NowMap].Ladders[n].Levels[5].IsHere;
            Pregen5.ItemIndex := SpecialMaps[NowMap].Ladders[n].Levels[5].PregenLevel;
            Cool5.Text := IntToStr(SpecialMaps[NowMap].Ladders[n].Levels[5].CoolLevel);
            Type5.Text := IntToStr(SpecialMaps[NowMap].Ladders[n].Levels[5].DungeonType);
            //
            CheckBox6.Checked := SpecialMaps[NowMap].Ladders[n].Levels[6].IsHere;
            Pregen6.ItemIndex := SpecialMaps[NowMap].Ladders[n].Levels[6].PregenLevel;
            Cool6.Text := IntToStr(SpecialMaps[NowMap].Ladders[n].Levels[6].CoolLevel);
            Type6.Text := IntToStr(SpecialMaps[NowMap].Ladders[n].Levels[6].DungeonType);
            //
            CheckBox7.Checked := SpecialMaps[NowMap].Ladders[n].Levels[7].IsHere;
            Pregen7.ItemIndex := SpecialMaps[NowMap].Ladders[n].Levels[7].PregenLevel;
            Cool7.Text := IntToStr(SpecialMaps[NowMap].Ladders[n].Levels[7].CoolLevel);
            Type7.Text := IntToStr(SpecialMaps[NowMap].Ladders[n].Levels[7].DungeonType);
            //
            CheckBox8.Checked := SpecialMaps[NowMap].Ladders[n].Levels[8].IsHere;
            Pregen8.ItemIndex := SpecialMaps[NowMap].Ladders[n].Levels[8].PregenLevel;
            Cool8.Text := IntToStr(SpecialMaps[NowMap].Ladders[n].Levels[8].CoolLevel);
            Type8.Text := IntToStr(SpecialMaps[NowMap].Ladders[n].Levels[8].DungeonType);
            //
            CheckBox9.Checked := SpecialMaps[NowMap].Ladders[n].Levels[9].IsHere;
            Pregen9.ItemIndex := SpecialMaps[NowMap].Ladders[n].Levels[9].PregenLevel;
            Cool9.Text := IntToStr(SpecialMaps[NowMap].Ladders[n].Levels[9].CoolLevel);
            Type9.Text := IntToStr(SpecialMaps[NowMap].Ladders[n].Levels[9].DungeonType);
            //
            CheckBox10.Checked := SpecialMaps[NowMap].Ladders[n].Levels[10].IsHere;
            Pregen10.ItemIndex := SpecialMaps[NowMap].Ladders[n].Levels[10].PregenLevel;
            Cool10.Text := IntToStr(SpecialMaps[NowMap].Ladders[n].Levels[10].CoolLevel);
            Type10.Text := IntToStr(SpecialMaps[NowMap].Ladders[n].Levels[10].DungeonType);
          end;
        end else
        // Свойства лестницы вверх
        if M.Tile[CurX, CurY] = tdUSTAIRS then
        begin
          // Открыть окно свойств
          with GroupBox7 do
          begin
            GroupBox2.Visible := False;
            Visible := True;
            with Pregen do
            begin
              ItemIndex := 0;
              Items.Clear;
              Items.Add('- Рандомная -');
              for i:=1 to MaxMaps do
                if SpecialMaps[i].Map.Special > 0 then
                  Items.Add(IntToStr(i) + ' - '+SpecialMaps[i].name);
              ItemIndex := SpecialMaps[NowMap].LadderUp;
            end;
          end;
        end;
      end else
        // Кровь
        if BloodMode.ItemIndex = 1 then
          M.Blood[CurX, CurY] := Random(2)+1 else
            // Тайл монстр
            case NowElement of
              1 : //Тайл
              M.Tile[CurX, CurY] := ItemsBox.ItemIndex+1;
              2 : //Монстр
              CreateMonster(ItemsBox.ItemIndex+1,CurX,CurY);
            end;
    end;
    // Удалить? (ПКМ)
    if ssRight in Shift then
    begin
      // Кровь
      if BloodMode.ItemIndex = 1 then
        M.Blood[CurX, CurY] := 0 else
          case NowElement of
            1 : //Тайл
            M.Tile[CurX, CurY] := 0;
            2 : //Монстр
            begin
                FillMemory(@M.MonL[M.MonP[CurX, CurY]], SizeOf(M.MonL[M.MonP[CurX, CurY]]), 0);
                M.MonP[CurX, CurY] := 0;
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
  i : integer;
begin
  case NowElement of
    1 : //Тайлы
    begin
      GroupBox1.Caption := 'Тайлы';
      ItemsBox.Items.Clear;
      for i:=1 to LevelTilesAmount do
        ItemsBox.Items.Add(TilesData[i].name);
      SetTiles.Font.Style := [fsBold];
    end;
    2 : //Монстры
    begin
      GroupBox1.Caption := 'Монстры';
      ItemsBox.Items.Clear;
      for i:=1 to MonstersAmount do
        ItemsBox.Items.Add(MonstersData[i].name1);
      SetMonsters.Font.Style := [fsBold];
    end;
  end;
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

{ Список карт }
procedure TMainEdForm.refreshMapList;
var
  i : byte;
begin
  MapList.Items.Clear;
  for i:=1 to MaxMaps do
    if SpecialMaps[i].Map.Special > 0 then
    begin
      if SpecialMaps[i].Map.Special <> i then
        SpecialMaps[i].Map.Special := i;
      MapList.Items.Add(IntToStr(SpecialMaps[i].Map.Special) + ' - '+SpecialMaps[i].name);
    end;
  MapList.Items.Add('-- Создать новую --');
  MapList.ItemIndex := NowMap-1;
end;

procedure TMainEdForm.N2Click(Sender: TObject);
var
  x,y,i : byte;
  h : boolean;
begin
  SaveSpecialMaps;
  // Проверка
  for i:=1 to MaxMaps do
    if SpecialMaps[i].Map.Special > 0 then
    begin
      h := false;
      for x:=1 to MapX do
        for y:=1 to MapY do
          If SpecialMaps[i].Map.Tile[x,y] = tdUSTAIRS then
            h := true;
      if (h) and (SpecialMaps[i].LadderUp = 0) then
        MsgBox('В локации "'+SpecialMaps[i].name+'" не определены свойства лестницы вверх!');
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
    MsgBox('Для начала необходимо выбрать карту!') else
      WaitForLadderClick := True;
end;

{ Применить изменения в свойствах лестницы }
procedure TMainEdForm.Button7Click(Sender: TObject);
begin
  WaitForLadderClick := False;
  with GroupBox6 do
  begin
    if (RandomName.Checked) or (DungeonName.Text = '') then
      SpecialMaps[NowMap].Ladders[n].name := '' else
        SpecialMaps[NowMap].Ladders[n].name := DungeonName.Text;
    //
    SpecialMaps[NowMap].Ladders[n].Levels[1].IsHere := CheckBox1.Checked;
    SpecialMaps[NowMap].Ladders[n].Levels[1].PregenLevel := Pregen1.ItemIndex;
    SpecialMaps[NowMap].Ladders[n].Levels[1].CoolLevel := StrToInt(Cool1.Text);
    SpecialMaps[NowMap].Ladders[n].Levels[1].DungeonType := StrToInt(Type1.Text);
    //
    SpecialMaps[NowMap].Ladders[n].Levels[2].IsHere := CheckBox2.Checked;
    SpecialMaps[NowMap].Ladders[n].Levels[2].PregenLevel := Pregen2.ItemIndex;
    SpecialMaps[NowMap].Ladders[n].Levels[2].CoolLevel := StrToInt(Cool2.Text);
    SpecialMaps[NowMap].Ladders[n].Levels[2].DungeonType := StrToInt(Type2.Text);
    //
    SpecialMaps[NowMap].Ladders[n].Levels[3].IsHere := CheckBox3.Checked;
    SpecialMaps[NowMap].Ladders[n].Levels[3].PregenLevel := Pregen3.ItemIndex;
    SpecialMaps[NowMap].Ladders[n].Levels[3].CoolLevel := StrToInt(Cool3.Text);
    SpecialMaps[NowMap].Ladders[n].Levels[3].DungeonType := StrToInt(Type3.Text);
    //
    SpecialMaps[NowMap].Ladders[n].Levels[4].IsHere := CheckBox4.Checked;
    SpecialMaps[NowMap].Ladders[n].Levels[4].PregenLevel := Pregen4.ItemIndex;
    SpecialMaps[NowMap].Ladders[n].Levels[4].CoolLevel := StrToInt(Cool4.Text);
    SpecialMaps[NowMap].Ladders[n].Levels[4].DungeonType := StrToInt(Type4.Text);
    //
    SpecialMaps[NowMap].Ladders[n].Levels[5].IsHere := CheckBox5.Checked;
    SpecialMaps[NowMap].Ladders[n].Levels[5].PregenLevel := Pregen5.ItemIndex;
    SpecialMaps[NowMap].Ladders[n].Levels[5].CoolLevel := StrToInt(Cool5.Text);
    SpecialMaps[NowMap].Ladders[n].Levels[5].DungeonType := StrToInt(Type5.Text);
    //
    SpecialMaps[NowMap].Ladders[n].Levels[6].IsHere := CheckBox6.Checked;
    SpecialMaps[NowMap].Ladders[n].Levels[6].PregenLevel := Pregen6.ItemIndex;
    SpecialMaps[NowMap].Ladders[n].Levels[6].CoolLevel := StrToInt(Cool6.Text);
    SpecialMaps[NowMap].Ladders[n].Levels[6].DungeonType := StrToInt(Type6.Text);
    //
    SpecialMaps[NowMap].Ladders[n].Levels[7].IsHere := CheckBox7.Checked;
    SpecialMaps[NowMap].Ladders[n].Levels[7].PregenLevel := Pregen7.ItemIndex;
    SpecialMaps[NowMap].Ladders[n].Levels[7].CoolLevel := StrToInt(Cool7.Text);
    SpecialMaps[NowMap].Ladders[n].Levels[7].DungeonType := StrToInt(Type7.Text);
    //
    SpecialMaps[NowMap].Ladders[n].Levels[8].IsHere := CheckBox8.Checked;
    SpecialMaps[NowMap].Ladders[n].Levels[8].PregenLevel := Pregen8.ItemIndex;
    SpecialMaps[NowMap].Ladders[n].Levels[8].CoolLevel := StrToInt(Cool8.Text);
    SpecialMaps[NowMap].Ladders[n].Levels[8].DungeonType := StrToInt(Type8.Text);
    //
    SpecialMaps[NowMap].Ladders[n].Levels[9].IsHere := CheckBox9.Checked;
    SpecialMaps[NowMap].Ladders[n].Levels[9].PregenLevel := Pregen9.ItemIndex;
    SpecialMaps[NowMap].Ladders[n].Levels[9].CoolLevel := StrToInt(Cool9.Text);
    SpecialMaps[NowMap].Ladders[n].Levels[9].DungeonType := StrToInt(Type9.Text);
    //
    SpecialMaps[NowMap].Ladders[n].Levels[10].IsHere := CheckBox10.Checked;
    SpecialMaps[NowMap].Ladders[n].Levels[10].PregenLevel := Pregen10.ItemIndex;
    SpecialMaps[NowMap].Ladders[n].Levels[10].CoolLevel := StrToInt(Cool10.Text);
    SpecialMaps[NowMap].Ladders[n].Levels[10].DungeonType := StrToInt(Type10.Text);
    //
    if NumberChange.ItemIndex > 0 then
      if SpecialMaps[NowMap].Ladders[NumberChange.ItemIndex].x = 0 then
      begin
        SpecialMaps[NowMap].Ladders[NumberChange.ItemIndex] := SpecialMaps[NowMap].Ladders[n];
        FillMemory(@SpecialMaps[NowMap].Ladders[n], SizeOf(SpecialMaps[NowMap].Ladders[n]), 0);
      end;
    Visible := False;
    GroupBox2.Visible := True;
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
  GroupBox2.Visible := True;
end;

procedure TMainEdForm.ListBox1Click(Sender: TObject);
begin
  OnPaint(Sender);
end;

procedure TMainEdForm.SpeedButton1Click(Sender: TObject);
var
  i,x,y : byte;
begin
  for x:=1 to MapX do
    for y:=1 to MapY do
      M.MonP[x,y] := 0;
  for i:=1 to 255 do
    FillMemory(@M.MonL[i], SizeOf(M.MonL[i]), 0);
end;

procedure TMainEdForm.Button2Click(Sender: TObject);
begin
  if NowMap = 0 then
    MsgBox('Для начала необходимо выбрать карту!') else
      WaitForMonsterClick := True; 
end;

{ Свойства монстра }
procedure TMainEdForm.Button3Click(Sender: TObject);
begin
  WaitForMonsterClick := False;
  with GroupBox8 do
  begin
    M.MonL[M.MonP[StrToInt(label4.Caption), StrToInt(label5.Caption)]].relation := relation.ItemIndex;
    Visible := False;
  end;
  GroupBox2.Visible := True;
end;

// Обновить лестницы, удалить несуществующие
procedure TMainEdForm.SpeedButton2Click(Sender: TObject);
var
  i : byte;
begin
  for i:=1 to MaxLadders do
    with SpecialMaps[NowMap].Ladders[i] do
    begin
      if (M.Tile[X, Y] <> tdDSTAIRS) and (M.Tile[X, Y] <> tdCHATCH) and
           (M.Tile[X, Y] <> tdDUNENTER) then
             begin
                x := 0;
                y := 0;
             end;
    end;
end;

procedure TMainEdForm.RandomNameClick(Sender: TObject);
begin
  if RandomName.Checked then DungeonName.Enabled := FALSE else DungeonName.Enabled := TRUE;
end;

end.
