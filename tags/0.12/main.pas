unit main;

interface

uses
  Windows, Classes, Graphics, Forms, SysUtils, ExtCtrls, Controls, StdCtrls, Dialogs;

type
  TMainForm = class(TForm)
    Edit: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ProcessMsg;
    procedure EndGame;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormResize(Sender: TObject);
    procedure EditKeyPress(Sender: TObject; var Key: Char);
  private
    procedure CMDialogKey( Var msg: TCMDialogKey );
    message CM_DIALOGKEY;
  public
  end;

var
  MainForm             : TMainForm;
  Screen               : TBitMap;              // Картинка для двойной-буфферизации
  WaitMore             : boolean;              // --Далее--
  WaitEnter            : boolean;              // Ждем нажатия Enter
  GameState            : byte;                 // Состояние игры
  Answer               : string[1];            // Ожидается ответ
  AskForQuit           : boolean;              // Подтверждение выхода
  MenuSelected,
  MenuSelected2        : byte;                 // Выбранный элемент в меню
  WasEq                : boolean;              // Перед вызовом меню действий с предметом был инвентарь или экипировка
  a                    : integer;
  wtd                  : byte;                 // Что сделать при выборе монстра
  HealthBar            : boolean;              // Отображать хелс-бары

implementation

{$R *.dfm}

uses
  Cons, Utils, Msg, Player, Map, Tile, Help, Items, Ability, MapEditor;

{ Инициализация }
procedure TMainForm.FormCreate(Sender: TObject);
begin
  // Загрузка карт
  if not MainEdForm.LoadSpecialMaps then
  begin
    ShowMessage('Ошибка загрузки файла maps.dp!');
    Halt;
  end;
  // Рамеры окна
  ClientWidth := WindowX * CharX;
  ClientHeight := WindowY * CharY;
  // Создаем картинку
  Screen := TBitMap.Create;
  Screen.Width := ClientWidth;
  Screen.Height := ClientHeight;
  Screen.Canvas.Font.Name := FontName;
  GameState := gsHEROGENDER;
  MenuSelected := 1;
end;

{ Отрисовка }
procedure TMainForm.FormPaint(Sender: TObject);
begin
  // Заполняем картинку черным цветом
  Screen.Canvas.Brush.Color := 0;
  Screen.Canvas.FillRect(Rect(0, 0, MainForm.ClientRect.Right, MainForm.ClientRect.Bottom));
  // Выводим
  case GameState of
    gsPLAY, gsCLOSE, gsLOOK, gsCHOOSEMONSTER, gsOPEN:
    begin
      // Выводим карту
      M.DrawScene;
      // Выводим сообщения
      ShowMsgs;
      // Вывести информацию о герое
      pc.WriteInfo;
    end;
    gsQUESTLIST  : pc.QuestList;
    gsEQUIPMENT  : pc.Equipment;
    gsINVENTORY  : pc.Inventory;
    gsHELP       : ShowHelp;
    gsUSEMENU    : begin if WasEq then pc.Equipment else pc.Inventory; pc.UseMenu; end;
    gsHERONAME   : pc.HeroName;
    gsHEROGENDER : pc.HeroGender;
    gsABILITYS   : ShowAbilitys;
    gsHISTORY    : ShowHistory;
  end;
  // Отобразить
  Canvas.StretchDraw(ClientRect, Screen);
end;

{ Нажатие на клавиши }
procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // Если кнопка не Shift, Alt или Ctrl И сейчас не ожидается ответ
  if Key <> 16 then
  begin
  // Скриншот
  if Key = 116 then TakeScreenShot else
    // Пробел для продолжения
    if WaitMore then
    begin
      if Key = 32 then WaitMore := False;
    end else
      // Enter для продолжения
      if WaitENTER then
      begin
        if Key = 13 then WaitENTER := False;
      end else
        // Вопрос
        if Answer = ' ' then
        begin
          if key = 32 then Answer := '' else Answer := UpCase (Chr(Key));
        end else
      // Все остальное
      begin
        ClearMsg;
        pc.turn := 0;
        case GameState of
          // Выбор пола
          gsHEROGENDER:
          begin
            case Key of
              // Вверх
              38,104,56 :
              begin
                if MenuSelected = 1 then MenuSelected := 2 else dec(MenuSelected);
                OnPaint(SENDER);
              end;
              // Вниз
              40,98,50 :
              begin
                if MenuSelected = 2 then MenuSelected := 1 else inc(MenuSelected);
                OnPaint(SENDER);
              end;
              // Ok...
              13 :
              begin
                pc.gender := MenuSelected;
                GameState := gsHERONAME;
                OnPaint(Sender);
              end;
            end;
          end;
          // Во время игры
          gsPLAY:
          begin
            { Передвижение по диагонали alt+две стрелки}
            if ssAlt in Shift then
            begin
              If ((GetKeyState(VK_LEFT) AND 128)=128) and ((GetKeyState(VK_DOWN) AND 128)=128) then
                pc.Move(-1,1) else
              If ((GetKeyState(VK_RIGHT) AND 128)=128) and ((GetKeyState(VK_DOWN) AND 128)=128) then
                pc.Move(1,1) else
              If ((GetKeyState(VK_LEFT) AND 128)=128) and ((GetKeyState(VK_UP) AND 128)=128) then
                pc.Move(-1,-1) else
              If ((GetKeyState(VK_RIGHT) AND 128)=128) and ((GetKeyState(VK_UP) AND 128)=128) then
                pc.Move(1,-1);
            end else
            case Key of
              { Передвижение }
              35,97,49     : pc.Move(-1,1);
              40,98,50     : pc.Move(0,1);
              34,99,51     : pc.Move(1,1);
              37,100,52    : pc.Move(-1,0);
              12,101,53,32 : pc.Move(0,0);
              39,102,54    : pc.Move(1,0);
              36,103,55    : pc.Move(-1,-1);
              38,104,56    : pc.Move(0,-1);
              33,105,57    : pc.Move(1,-1);
              13           : pc.UseStairs;
              { Комманды }
              // Выйти 'Esc'
              27        : Close;
              // Закрыть дверь 'c'
              67        : pc.SearchForDoors;
              // Смотреть 'l'
              76        :
              begin
                GameState := gsLOOK;
                lx := pc.x;
                ly := pc.y;
                pc.AnalysePlace(lx,ly,TRUE);
              end;
              // Говорить 't'
              84        : pc.SearchForAlive(2);
              // Список квестов 'q'
              81        :
              begin
                GameState := gsQUESTLIST;
              end;
              // Экипировка 'e'
              69        :
              begin
                MenuSelected := 1;
                GameState := gsEQUIPMENT;
              end;
              // Инвентарь 'i'
              73        :
              if pc.ItemsAmount > 0 then
              begin
                MenuSelected := 1;
                GameState := gsINVENTORY;
              end else
                AddMsg('Твой инвентарь пуст!');
              // Помощь '?'
              112       :
              begin
                GameState := gsHELP;
              end;
              // Атаковать 'a'
              65        : pc.SearchForAlive(1);
              // Поднять 'g'
              71        :
              case pc.PickUp(M.Item[pc.x,pc.y], FALSE) of
                0 :
                begin
                  AddMsg('Ты поднимаешь '+ItemName(M.Item[pc.x,pc.y], 1, TRUE)+'.');
                  M.Item[pc.x,pc.y].id := 0;
                end;
                1 : AddMsg('Здесь ничего не лежит!');
                2 : AddMsg('Твой инвентарь полностю забит! Как такое могло случиться?! Пора бы подумать о том, чтобы выкинуть или продать некоторые вещи...');
                3 : AddMsg('Ты не можешь нести больше... Слишком тяжело!');
              end;
              // Открыть 'o'
              79        :
              begin
                AddMsg('Что ты хочешь открыть?');
                GameState := gsOPEN;
              end;
              // Осмотреться 's'
              83        :
              begin
                AddMsg('Ты внимательно осматриваешься по сторонам...');
                pc.Search(1);
                pc.turn := 1;
              end;
              // Таланты 'x'
              88        :
              begin
                MenuSelected := 1;
                GameState := gsABILITYS;
              end;
              // История сообщений 'm'
              77        :
                GameState := gsHISTORY;
              // Отобразить хелс-бары '\'
              220       :
                HealthBar := not HealthBar;
              // Поменять тактику 'tab'
              VK_TAB    :
              begin
                case pc.tactic of
                   0 : AddMsg('Текущая тактика - {Стандартная}.');
                   1 : AddMsg('Текущая тактика - <Агрессивное нападение>.');
                   2 : AddMsg('Текущая тактика - [Защита].');
                end;
                case Ask('Выбрать тактику: ([A]) - Агрессивное нападение, ([S]) - Стандартная, ([D]) - Защищаться.') of
                  'A' :
                  begin
                    ClearMsg;
                    pc.tactic := 1;
                    AddMsg('Выбрано агрессивное нападение.');
                    AddMsg('Распределение шансов:');
                    AddMsg('[+50% к успешному попадению и урону], <-50% к уклонению и эффективности брони>.');
                  end;
                  'S' :
                  begin
                    ClearMsg;
                    pc.tactic := 0;
                    AddMsg('Выбрана стандартная тактика.');
                    AddMsg('Никаких плюсов и минусов во время боя.');
                  end;
                  'D' :
                  begin
                    ClearMsg;
                    pc.tactic := 2;
                    AddMsg('Выбрана защитная тактика.');
                    AddMsg('Распределение шансов:');
                    AddMsg('<-50% к успешному попадению и урону>, [+50% к уклонению и эффективности брони].');
                  end;
                  ELSE
                    AddMsg('Ты решил'+pc.HeSheIt(1)+' не менять тактику.');
                end;
              end;
            end;
          end;
          // Закрыть дверь
          gsCLOSE:
          begin
            case Key of
              35,97,49  : pc.CloseDoor(-1,1);
              40,98,50  : pc.CloseDoor(0,1);
              34,99,51  : pc.CloseDoor(1,1);
              37,100,52 : pc.CloseDoor(-1,0);
              39,102,54 : pc.CloseDoor(1,0);
              36,103,55 : pc.CloseDoor(-1,-1);
              38,104,56 : pc.CloseDoor(0,-1);
              33,105,57 : pc.CloseDoor(1,-1);
              else
                AddDrawMsg('Указано неправильное направление!');
            end;
            pc.turn := 1;
            GameState := gsPLAY;
          end;
          // Открыть
          gsOPEN:
          begin
            case Key of
              35,97,49  : pc.Open(-1,1);
              40,98,50  : pc.Open(0,1);
              34,99,51  : pc.Open(1,1);
              37,100,52 : pc.Open(-1,0);
              39,102,54 : pc.Open(1,0);
              36,103,55 : pc.Open(-1,-1);
              38,104,56 : pc.Open(0,-1);
              33,105,57 : pc.Open(1,-1);
              else
                AddDrawMsg('Указано неправильное направление!');
            end;
            pc.turn := 1;
            GameState := gsPLAY;
          end;
          // Атаковать!
          gsCHOOSEMONSTER:
          begin
            case Key of
              35,97,49  :
              case wtd of
                1 : pc.Fight(M.MonL[M.MonP[pc.x-1,pc.y+1]], 0);
                2 : pc.Talk(M.MonL[M.MonP[pc.x-1,pc.y+1]]);
                3 : if waseq then pc.GiveItem(M.MonL[M.MonP[pc.x-1,pc.y+1]], pc.Eq[MenuSelected]) else
                                      pc.GiveItem(M.MonL[M.MonP[pc.x-1,pc.y+1]], pc.Inv[MenuSelected]);
              end;
              40,98,50  :
              case wtd of
                1 : pc.Fight(M.MonL[M.MonP[pc.x,pc.y+1]], 0);
                2 : pc.Talk(M.MonL[M.MonP[pc.x,pc.y+1]]);
                3 : if waseq then pc.GiveItem(M.MonL[M.MonP[pc.x,pc.y+1]], pc.Eq[MenuSelected]) else
                                      pc.GiveItem(M.MonL[M.MonP[pc.x,pc.y+1]], pc.Inv[MenuSelected]);
              end;
              34,99,51  :
              case wtd of
                1 : pc.Fight(M.MonL[M.MonP[pc.x+1,pc.y+1]], 0);
                2 : pc.Talk(M.MonL[M.MonP[pc.x+1,pc.y+1]]);
                3 : if waseq then pc.GiveItem(M.MonL[M.MonP[pc.x+1,pc.y+1]], pc.Eq[MenuSelected]) else
                                      pc.GiveItem(M.MonL[M.MonP[pc.x+1,pc.y+1]], pc.Inv[MenuSelected]);
              end;
              37,100,52 :
              case wtd of
                1 : pc.Fight(M.MonL[M.MonP[pc.x-1,pc.y]], 0);
                2 : pc.Talk(M.MonL[M.MonP[pc.x-1,pc.y]]);
                3 : if waseq then pc.GiveItem(M.MonL[M.MonP[pc.x-1,pc.y]], pc.Eq[MenuSelected]) else
                                      pc.GiveItem(M.MonL[M.MonP[pc.x-1,pc.y]], pc.Inv[MenuSelected]);
              end;
              39,102,54 :
              case wtd of
                1 : pc.Fight(M.MonL[M.MonP[pc.x+1,pc.y]], 0);
                2 : pc.Talk(M.MonL[M.MonP[pc.x+1,pc.y]]);
                3 : if waseq then pc.GiveItem(M.MonL[M.MonP[pc.x+1,pc.y]], pc.Eq[MenuSelected]) else
                                      pc.GiveItem(M.MonL[M.MonP[pc.x+1,pc.y]], pc.Inv[MenuSelected]);
              end;
              36,103,55 :
              case wtd of
                1 : pc.Fight(M.MonL[M.MonP[pc.x-1,pc.y-1]], 0);
                2 : pc.Talk(M.MonL[M.MonP[pc.x-1,pc.y-1]]);
                3 : if waseq then pc.GiveItem(M.MonL[M.MonP[pc.x-1,pc.y-1]], pc.Eq[MenuSelected]) else
                                      pc.GiveItem(M.MonL[M.MonP[pc.x-1,pc.y-1]], pc.Inv[MenuSelected]);
              end;
              38,104,56 :
              case wtd of
                1 : pc.Fight(M.MonL[M.MonP[pc.x,pc.y-1]], 0);
                2 : pc.Talk(M.MonL[M.MonP[pc.x,pc.y-1]]);
                3 : if waseq then pc.GiveItem(M.MonL[M.MonP[pc.x,pc.y-1]], pc.Eq[MenuSelected]) else
                                      pc.GiveItem(M.MonL[M.MonP[pc.x,pc.y-1]], pc.Inv[MenuSelected]);
              end;
              33,105,57 :
              case wtd of
                1 : pc.Fight(M.MonL[M.MonP[pc.x+1,pc.y-1]], 0);
                2 : pc.Talk(M.MonL[M.MonP[pc.x+1,pc.y-1]]);
                3 : if waseq then pc.GiveItem(M.MonL[M.MonP[pc.x+1,pc.y-1]], pc.Eq[MenuSelected]) else
                                      pc.GiveItem(M.MonL[M.MonP[pc.x+1,pc.y-1]], pc.Inv[MenuSelected]);
              end;
              else
                AddDrawMsg('Указано неправильное направление!');
            end;
            pc.turn := 1;
            GameState := gsPLAY;
          end;
          // Управление курсором осмотра
          gsLOOK:
          begin
            case Key of
              35,97,49  : pc.MoveLook(-1,1);
              40,98,50  : pc.MoveLook(0,1);
              34,99,51  : pc.MoveLook(1,1);
              37,100,52 : pc.MoveLook(-1,0);
              12,101,53 : pc.MoveLook(0,0);
              39,102,54 : pc.MoveLook(1,0);
              36,103,55 : pc.MoveLook(-1,-1);
              38,104,56 : pc.MoveLook(0,-1);
              33,105,57 : pc.MoveLook(1,-1);
              else
                GameState := gsPlay;
              M.DrawScene;
            end;
          end;
          // Список квестов, экипировка, помощь
          gsQUESTLIST, gsEQUIPMENT, gsINVENTORY, gsHELP, gsABILITYS, gsHISTORY:
          begin
            if (Key = 27) or (Key = 32) then GameState := gsPLAY;
            // Управление в экипировке
            if GameState = gsEQUIPMENT then
            begin
              case Key of
                //i
                73 :
                if pc.ItemsAmount > 0 then
                begin
                  MenuSelected := 1;
                  pc.Inventory;
                  GameState := gsINVENTORY;
                end;
                // Вверх
                38,104,56 :
                  if MenuSelected = 1 then MenuSelected := EqAmount else dec(MenuSelected);
                // Вниз
                40,98,50 :
                  if MenuSelected = EqAmount then MenuSelected := 1 else inc(MenuSelected);
                // Снять / Войти в инвентарь
                13 :
                begin
                  // Снять
                  if pc.eq[MenuSelected].id > 0 then
                  begin
                    WasEq := TRUE;
                    MenuSelected2 := 1;
                    pc.UseMenu;
                    GameState := gsUSEMENU;
                  end else
                    begin
                      MenuSelected := 1;
                      pc.Inventory;
                      GameState := gsINVENTORY;
                    end;
                end;
              end;
            end ELSE
            // Управление в инвентаре
            if GameState = gsINVENTORY then
            begin
              case Key of
                //i
                73 :
                begin
                  MenuSelected := 1;
                  pc.Equipment;
                  GameState := gsEQUIPMENT;
                end;
                // Вверх
                38,104,56 :
                  if MenuSelected = 1 then MenuSelected := ReturnInvAmount else dec(MenuSelected);
                // Вниз
                40,98,50 :
                  if MenuSelected = ReturnInvAmount then MenuSelected := 1 else inc(MenuSelected);
                // Открыть список действий с предметом
                13 :
                begin
                  WasEq := FALSE;
                  MenuSelected2 := 1;
                  pc.UseMenu;
                  GameState := gsUSEMENU;
                end;
              end;
            end ELSE
            // Управление в списке способностей
            if GameState = gsABILITYS then
            begin
              case Key of
                // Вверх
                38,104,56 :
                begin
                  if MenuSelected = 1 then
                  begin
                    for a:=1 to AbilitysAmount-1 do
                      if FullAbilitys[a+1] = 0 then
                        break;
                     MenuSelected := a;
                  end
                    else
                      dec(MenuSelected);
                end;
                // Вниз
                40,98,50 :
                begin
                  for a:=1 to AbilitysAmount-1 do
                    if FullAbilitys[a+1] = 0 then
                      break;
                  if MenuSelected = a then MenuSelected := 1 else inc(MenuSelected);
                end;
              end;
            end;
          end;
          // Список действий над предметом
          gsUSEMENU:
          begin
            case Key of
              // Esc
              27 : if WasEq then GameState := gsEQUIPMENT else GameState := gsINVENTORY;
              // Вверх
              38,104,56 :
              begin
                if MenuSelected2 = 1 then MenuSelected2 := HOWMANYVARIANTS else dec(MenuSelected2);
                OnPaint(SENDER);
              end;
              // Вниз
              40,98,50 :
              begin
                if MenuSelected2 = HOWMANYVARIANTS then MenuSelected2 := 1 else inc(MenuSelected2);
                OnPaint(SENDER);
              end;
              // Сделать выбранное действие с предметом
              13 :
              begin
                case MenuSelected2 of
                  1: // Использовать
                  begin
                    GameState := gsPLAY;
                    //В экипировке
                    if WasEq then
                    begin
                      case pc.PickUp(pc.eq[MenuSelected], TRUE) of
                        0 :
                        begin
                          ItemOnOff(pc.eq[MenuSelected], FALSE);
                          AddMsg('Ты положил'+pc.HeSheIt(1)+' '+ItemName(pc.eq[MenuSelected], 1, TRUE)+' обратно в инвентарь.');
                          pc.eq[MenuSelected].id := 0;
                        end;
                        1 : AddMsg('<Ты положил'+pc.HeSheIt(1)+' пустоту обратно в свой инвентарь :)>');
                        2 : AddMsg('Твой инвентарь полностью забит! Так что тебе придется нести это в руках.');
                        3 : AddMsg('<Этого быть не должно - даже если у тебя перегрузка, ты можешь положить, то что ты уже несешь в инвентарь.>');
                      end;
                    end else
                      //В инвентаре
                      begin
                        // Считать монетки (ворюши должны становиться агрессивными к тебе и орать "Отдай деньги!")
                        if pc.Inv[MenuSelected].id = idCOIN then
                          begin
                            if pc.Inv[MenuSelected].amount = 1 then
                              AddMsg('Что тут пересчитывать - у тебя ровно одна золотая монетка...') else
                                AddMsg('Ты пересчитал'+pc.HeSheIt(1)+' '+ItemName(pc.Inv[MenuSelected],0, TRUE)+'.');
                            pc.turn := 1;
                          end else
                            // Использовать предмет по назначению
                            case ItemsData[pc.Inv[MenuSelected].id].vid of
                              // Надеть
                              1..13:
                              begin
                                case pc.EquipItem(pc.Inv[MenuSelected]) of
                                  0 :
                                  begin
                                    ItemOnOff(pc.Inv[MenuSelected], TRUE);
                                    if (pc.Inv[MenuSelected].amount > 1) and (ItemsData[pc.Inv[MenuSelected].id].vid <> 13) then
                                      dec(pc.Inv[MenuSelected].amount) else
                                        pc.Inv[MenuSelected].id := 0;
                                    pc.RefreshInventory;
                                    MenuSelected := Cell;
                                    GameState := gsEQUIPMENT;
                                  end;
                                  1 :
                                  begin
                                    ItemOnOff(pc.Inv[MenuSelected], TRUE);
                                    GameState := gsPLAY;
                                  end;
                                end;
                              end;
                              // Съесть
                              14:
                              begin
                                if pc.status[stHUNGRY] >= 0 then
                                begin
                                  pc.status[stHUNGRY] := pc.status[stHUNGRY] - Round(ItemsData[pc.Inv[MenuSelected].id].defense * pc.Inv[MenuSelected].mass * 1.3 * (1 + (pc.ability[abEATINSIDE] * AbilitysData[abEATINSIDE].koef) / 100));
                                  if pc.status[stHUNGRY] < -500 then
                                  begin
                                    AddMsg('[Ты не смог'+pc.HeSheIt(3)+' доесть '+ItemName(pc.Inv[MenuSelected], 1, FALSE)+', потому что очень насытил'+pc.HeSheIt(2)+'... чересчур насытил'+pc.HeSheIt(2)+'...]');
                                    pc.status[stHUNGRY] := -500;
                                  end else
                                      AddMsg('[Ты съел'+pc.HeSheIt(1)+' '+ItemName(pc.Inv[MenuSelected], 1, FALSE)+'.]');
                                  pc.DeleteInvItem(pc.Inv[MenuSelected], FALSE);
                                  pc.turn := 1;
                                end else
                                  AddMsg('Тебе не хочется больше есть!');
                              end;
                              // Выпить
                              19:
                              begin
                                AddMsg('Ты выпил'+pc.HeSheIt(1)+' '+ItemName(pc.Inv[MenuSelected], 1, FALSE)+'.');
                                // Лечение
                                if pc.Inv[MenuSelected].id = idPOTIONCURE then
                                begin
                                  if pc.Hp < pc.RHp then
                                  begin
                                    a := Random(11)+5;
                                    if pc.hp + a > pc.RHp then
                                      a := pc.RHp - pc.Hp;
                                    inc(pc.hp, a);
                                    if pc.Hp >= pc.RHp then
                                    begin
                                      AddMsg('[Ты полностью исцелил'+pc.HeSheIt(2)+'!] ({+'+IntToStr(a)+'})');
                                      pc.Hp := pc.RHp;
                                    end else
                                      AddMsg('[Тебе стало немного лучше] ({+'+IntToStr(a)+'})');
                                  end else
                                    AddMsg('Ничего не произошло.');
                                end;
                                // Исцеление
                                if pc.Inv[MenuSelected].id = idPOTIONHEAL then
                                begin
                                  if pc.Hp < pc.RHp then
                                  begin
                                    AddMsg('[Ты полностью исцелил'+pc.HeSheIt(2)+'!] ({+'+IntToStr(pc.RHp-pc.Hp)+'})');
                                    pc.Hp := pc.RHp;
                                  end else
                                    AddMsg('Ничего не произошло.');
                                end;
                                // Пивасик
                                if pc.Inv[MenuSelected].id = idCHEAPBEER then
                                begin
                                  if pc.status[stDRUNK] <= 500 then
                                  begin
                                    if pc.Hp < pc.RHp then
                                    begin
                                      a := Random(6)+1;
                                      inc(pc.hp, a);
                                      if pc.Hp >= pc.RHp then
                                      begin
                                        pc.Hp := pc.RHp;
                                        AddMsg('Это пиво - полная ерунда, но тем неменее ты теперь чувствуешь себя замечательно!');
                                      end else
                                        AddMsg('Не такое уж это пиво и плохое...');
                                    end else
                                      AddMsg('Ты довольно быстро осушил'+pc.HeSheIt(1)+' бутылку пива. Не плохо. Освежает!');
                                    inc(pc.status[stDRUNK], 130);
                                  end else
                                    AddMsg('Ты попытал'+pc.HeSheIt(2)+' выпить еще, но случайно бутылка выскользнула из твоих рук и разбилась!..');
                                end;
                                pc.DeleteInvItem(pc.Inv[MenuSelected], FALSE);
                                pc.turn := 1;
                              end;
                            end;
                          end;
                  end;
                  2: // Рассмотреть
                  begin
                    GameState := gsPLAY;
                    if WasEq then
                      ExamineItem(pc.Eq[MenuSelected]) else
                        ExamineItem(pc.Inv[MenuSelected]);
                    pc.turn := 1;
                  end;
                  3: // Бросить
                  begin
                  end;
                  4: // Отдать
                  begin
                    GameState :=gsPLAY;
                    pc.SearchForAlive(3);
                  end;
                  5: // Выкинуть
                  begin
                    GameState := gsPLAY;
                    if WasEq then
                    begin
                      if PutItem(pc.x,pc.y, pc.Eq[MenuSelected]) then
                      begin
                        AddMsg('Ты выкинул'+pc.HeSheIt(1)+' '+ItemName(pc.Eq[MenuSelected], 1, TRUE)+'.');
                        pc.DeleteInvItem(pc.Eq[MenuSelected], TRUE);
                        pc.turn := 1;
                      end else
                        AddMsg('Здесь нет места для того, что бы выкинуть что-либо!');
                    end else
                      begin
                        if PutItem(pc.x,pc.y, pc.Inv[MenuSelected]) then
                        begin
                          AddMsg('Ты выкинул'+pc.HeSheIt(1)+' '+ItemName(pc.Inv[MenuSelected], 1, TRUE)+'.');
                          pc.DeleteInvItem(pc.Inv[MenuSelected], TRUE);
                          pc.turn := 1;
                        end else
                          AddMsg('Здесь нет места для того, что бы выкинуть что-либо!');
                      end;
                  end;
                end;
              end;
            end;
          end;
        end;
        pc.AfterTurn;
      end;
    end;
end;

{ Обработка сигналов }
procedure TMainForm.ProcessMsg;
begin
  Application.ProcessMessages;
end;

{ Завершить игру }
procedure TMainForm.EndGame;
begin
  // Удаляем сохранения
  DeleteSwap;
end;

{ Выйти из игры }
procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := FALSE;
  if (pc.Hp <= 0) or (AskForQuit = False) then
  begin
    EndGame;
    CanClose := TRUE;
  end else
    if (GameState = gsPLAY) or (GameState = gsLOOK) or (GameState = gsCLOSE) or (GameState = gsCHOOSEMONSTER) then
    begin
      if (Ask('Покинуть мир, совершив суицид? [(Y/n)]')) = 'Y' then
      begin
        CanClose := TRUE;
        EndGame;
      end else
        AddMsg('Ты решил'+pc.HeSheIt(1)+' пожить еще чуть-чуть.');
    end else
      begin
        if (GameState <> gsHEROGENDER) and (GameState <> gsHERONAME) then
        begin
          GameState := gsPLAY;
          OnPaint(SENDER);
        end;
      end;
end;

{ Развернуть - свернуть окно }
procedure TMainForm.FormResize(Sender: TObject);
begin
  if GameState > 0 then
    OnPaint(Sender);
end;

{ Нажатие в Edit'e}
procedure TMainForm.EditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    if Edit.Text = '' then
    begin
      case pc.gender of
        genMALE   : pc.name := GenerateName(FALSE);
        genFEMALE : pc.name := GenerateName(TRUE);
      end;
    end else
      pc.name := Edit.Text;
    Edit.Visible := False;
    GameState := gsPLAY;
    // Инициализация игры
    AskForQuit := TRUE;
    M.Clear;
    M := SpecialMaps[1].Map;
    // Поместить героя
    pc.PlaceHere(6,18);
    pc.Prepare;
    pc.FOV;
    Addmsg('{Очень теплый и ясный день.}');
    Addmsg('После нескольких недель странствия, ты, наконец, прибыл'+pc.HeSheIt(1)+' в деревушку Эвилиар.');
    Addmsg('Ходят слухи, что здесь творятся странные вещи. Ты хочешь разобраться в этом.');
    Addmsg(' ');
    Addmsg('Нажми ([F1]), если нужна помощь.');
    OnPaint(Sender);
    Key := #0;
  end;
end;

{ Это нужно что бы TAB обработать }
procedure TMainForm.CMDialogKey(var msg: TCMDialogKey);
begin
  if msg.Charcode <> VK_TAB then inherited;
end;

end.
