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
    procedure InitGame;
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
  VidFilter            : byte;                 // Предметы какого вида отоброжать в инвентаре (0-все)
  WasEq                : boolean;              // Перед вызовом меню действий с предметом был инвентарь или экипировка
  a                    : integer;
  wtd                  : byte;                 // Что сделать при выборе монстра

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
  GameState := gsINTRO;
  pc.id := 1;
  pc.idinlist := 1;
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
    gsPLAY, gsCLOSE, gsLOOK, gsCHOOSEMONSTER, gsOPEN, gsAIM:
    begin
      // Выводим карту
      M.DrawScene;
      // Выводим сообщения
      ShowMsgs;
      // Вывести информацию о герое
      pc.WriteInfo;
    end;
    gsQUESTLIST    : pc.QuestList;
    gsEQUIPMENT    : pc.Equipment;
    gsINVENTORY    : pc.Inventory;
    gsHELP         : ShowHelp;
    gsUSEMENU      : begin if WasEq then pc.Equipment else pc.Inventory; pc.UseMenu; end;
    gsHERONAME     : pc.HeroName;
    gsHEROATR      : pc.HeroAtributes;
    gsHEROGENDER   : pc.HeroGender;
    gsHEROCRRESULT : pc.HeroCreateResult;
    gsHEROCLWPN    : pc.HeroCloseWeapon;
    gsHEROFRWPN    : pc.HeroFarWeapon;
    gsABILITYS     : ShowAbilitys;
    gsHISTORY      : ShowHistory;
    gsINTRO        : Intro;
    gsSKILLSMENU   : SkillsAndAbilitys;
    gsWPNSKILLS    : WpnSkills;
  end;
  // Отобразить
  Canvas.StretchDraw(ClientRect, Screen);
end;

{ Нажатие на клавиши }
procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i : byte;
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
          // Заставка
          gsINTRO:
          begin
            case Key of
              13, 32 : GameState := gsHEROGENDER;
            end;
          end;
          // Выбор пола
          gsHEROGENDER:
          begin
            case Key of
              // Вверх
              38,104,56 :
              begin
                if MenuSelected = 1 then MenuSelected := 3 else dec(MenuSelected);
                OnPaint(SENDER);
              end;
              // Вниз
              40,98,50 :
              begin
                if MenuSelected = 3 then MenuSelected := 1 else inc(MenuSelected);
                OnPaint(SENDER);
              end;
              // Ok...
              13 :
              begin
                if MenuSelected < 3 then pc.gender := MenuSelected else pc.gender := Random(2)+1;
                MenuSelected := 1;
                MenuSelected2 := 1;
                GameState := gsHERONAME;
                OnPaint(Sender);
              end;
            end;
          end;
          // Выбор оружия бл. боя
          gsHEROCLWPN:
          begin
            case Key of
              // Вверх
              38,104,56 :
              begin
                if MenuSelected > 1 then dec(MenuSelected) else
                  for i:= 5 downto 1 do
                    if WList[i] > 0 then
                      begin
                        MenuSelected := i;
                        break;
                      end;
                OnPaint(SENDER);
              end;
              // Вниз
              40,98,50 :
              begin
                if MenuSelected < 5 then
                begin
                  if WList[MenuSelected+1] > 0 then
                    inc(MenuSelected) else
                      MenuSelected := 1;
                end else
                  MenuSelected := 1;
                OnPaint(SENDER);
              end;
              // Ok...
              13 :
              begin
                c_choose := Wlist[MenuSelected];
                MenuSelected := 1;
                MenuSelected2 := 1;
                if (HowManyBestWPNFR > 1) and not ((HowManyBestWPNFR < 3) and (OneOfTheBestWPNFR(FAR_THROW)))  then
                  GameState := gsHEROFRWPN else
                    GameState := gsHEROCRRESULT;
                OnPaint(Sender);
              end;
            end;
          end;
          // Выбор оружия дальнего боя
          gsHEROFRWPN:
          begin
            case Key of
              // Вверх
              38,104,56 :
              begin
                if MenuSelected > 1 then dec(MenuSelected) else
                  for i:= 4 downto 1 do
                    if WList[i] > 0 then
                      begin
                        MenuSelected := i;
                        break;
                      end;
                OnPaint(SENDER);
              end;
              // Вниз
              40,98,50 :
              begin
                if MenuSelected < 4 then
                begin
                  if WList[MenuSelected+1] > 0 then
                    inc(MenuSelected) else
                      MenuSelected := 1;
                end else
                  MenuSelected := 1;
                OnPaint(SENDER);
              end;
              // Ok...
              13 :
              begin
                f_choose := Wlist[MenuSelected];
                MenuSelected := 1;
                MenuSelected2 := 1;
                GameState := gsHEROCRRESULT;
                OnPaint(Sender);
              end;
            end;
          end;
          // Выбор атрибутов
          gsHEROATR:
          begin
            case Key of
              // Вверх
              38,104,56 :
              begin
                if MenuSelected = 1 then MenuSelected := 3 else dec(MenuSelected);
                OnPaint(SENDER);
              end;
              // Вниз
              40,98,50 :
              begin
                if MenuSelected = 3 then MenuSelected := 1 else inc(MenuSelected);
                OnPaint(SENDER);
              end;
              // Ok...
              13 :
              begin
                pc.atr[MenuSelected2] := MenuSelected;
                if MenuSelected2 = 1 then
                begin
                  MenuSelected := 1;
                  inc(MenuSelected2);
                end else
                  begin
                    MenuSelected := 1;
                    // Добавить очки умений исходя из класса
                    pc.Prepare;
                    pc.PrepareSkills;
                    if (HowManyBestWPNCL > 1) and not ((HowManyBestWPNCL < 3) and (OneOfTheBestWPNCL(CLOSE_TWO))) then
                      GameState := gsHEROCLWPN else
                        if (HowManyBestWPNFR > 1) and not ((HowManyBestWPNFR < 3) and (OneOfTheBestWPNFR(FAR_THROW))) then
                          GameState := gsHEROFRWPN else
                            GameState := gsHEROCRRESULT;
                  end;
                OnPaint(Sender);
              end;
            end;
          end;
          // Подтвердить
          gsHEROCRRESULT:
          begin
            case Key of
              13, 32 :
              begin
                pc.FavWPNSkill;
                M.MonL[pc.idinlist] := pc;
                InitGame;
              end;
              27     :
              begin
                MenuSelected := 1;
                GameState := gsHEROGENDER;
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
                pc.AnalysePlace(lx,ly,2);
              end;
              // Говорить 't'
              84        : pc.SearchForAlive(2);
              // Список квестов 'q'
              81        :
              begin
                GameState := gsQUESTLIST;
              end;
              // Съесть 'f'
              70        :
              begin
                if pc.HaveItemVid(14) then
                begin
                  MenuSelected := 1;
                  VidFilter := 14;
                  GameState := gsINVENTORY;
                end else
                  AddMsg('У тебя нет ничего съестного!');
              end;
              // Выпить 'd'
              68        :
              begin
                if pc.HaveItemVid(19) then
                begin
                  MenuSelected := 1;
                  VidFilter := 19;
                  GameState := gsINVENTORY;
                end else
                  AddMsg('В инвентаре нет ничего что можно выпить!');
              end;
              // Экипировка 'e'
              69        :
              begin
                  MenuSelected := 1;
                  GameState := gsEQUIPMENT;
              end;
              // Инвентарь 'i'
              73        :
              begin
                if pc.ItemsAmount > 0 then
                begin
                  MenuSelected := 1;
                  VidFilter := 0;
                  GameState := gsINVENTORY;
                end else
                  AddMsg('Твой инвентарь пуст!');
              end;
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
              // Войти в меню Навыки и Способности 'x'
              88        :
              begin
                MenuSelected := 1;
                GameState := gsSKILLSMENU;
              end;
              // История сообщений 'm'
              77        :
                GameState := gsHISTORY;
              // Стрелять 's'
              83       :
              begin
                if (pc.eq[13].id > 0) then
                begin
                  AddMsg('{Целиться в:}');
                  i := pc.SearchForAliveField;
                  if autoaim > 0 then
                    if (M.Saw[M.MonL[autoaim].x, M.MonL[autoaim].y] = 2) and (M.MonL[autoaim].id > 0) then
                      i := autoaim;
                  if i > 0 then
                  begin
                    lx := M.MonL[i].x;
                    ly := M.MonL[i].y;
                    pc.AnalysePlace(lx,ly,1);
                    GameState := gsAIM;
                  end else
                    AddMsg('В пределах видимости нет живых существ!');
                end else
                  AddMsg('Слот аммуниции в экипировке пуст!');
              end;
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
          // Управление курсором прицела
          gsAIM:
          begin
            case Key of
              35,97,49  : pc.MoveAim(-1,1);
              40,98,50  : pc.MoveAim(0,1);
              34,99,51  : pc.MoveAim(1,1);
              37,100,52 : pc.MoveAim(-1,0);
              12,101,53 : pc.MoveAim(0,0);
              39,102,54 : pc.MoveAim(1,0);
              36,103,55 : pc.MoveAim(-1,-1);
              38,104,56 : pc.MoveAim(0,-1);
              33,105,57 : pc.MoveAim(1,-1);
              13        :
                if M.MonP[lx,ly] > 0 then
                begin
                  autoaim := M.MonP[lx,ly];
                  pc.Fire(M.MonL[M.MonP[lx,ly]]);
                  dec(pc.Eq[13].amount);
                  if pc.eq[13].amount = 0 then
                  begin
                    AddMsg('<У тебя закончились '+ItemsData[pc.eq[13].id].name2+'!>');
                    pc.eq[13].id := 0;
                  end;
                  pc.turn := 1;
                  GameState := gsPLAY;
                end;
              else
                GameState := gsPlay;
              M.DrawScene;
            end;
          end;
          // Список квестов, экипировка, помощь
          gsQUESTLIST, gsEQUIPMENT, gsINVENTORY, gsHELP, gsABILITYS, gsHISTORY, gsSKILLSMENU,
          gsUSEMENU, gsWPNSKILLS:
          begin
            if (Key = 27) or (Key = 32) then GameState := gsPLAY;
            // Чит в навыках
            if GameState = gsWPNSKILLS then
            begin
              case Key of
                // Отобразить проценты '\'
                220 :
                begin
                  ShowProc := not ShowProc;
                  OnPaint(SENDER);
                end;
              end;

            end ELSE

            // Управление в экипировке
            if GameState = gsEQUIPMENT then
            begin
              case Key of
                //i
                73 :
                if pc.ItemsAmount > 0 then
                begin
                  MenuSelected := 1;
                  VidFilter := 0;
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
                    if pc.HaveItemVid(Eq2Vid(MenuSelected)) then
                    begin
                      VidFilter := Eq2Vid(MenuSelected);
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
                  if VidFilter = 0 then
                  begin
                    if MenuSelected = 1 then MenuSelected := ReturnInvAmount else dec(MenuSelected);
                  end else
                    if MenuSelected = 1 then MenuSelected := ReturnInvListAmount else dec(MenuSelected);
                // Вниз
                40,98,50 :
                  if VidFilter = 0 then
                  begin
                    if MenuSelected = ReturnInvAmount then MenuSelected := 1 else inc(MenuSelected);
                  end else
                    if MenuSelected = ReturnInvListAmount then MenuSelected := 1 else inc(MenuSelected);
                // Открыть список действий с предметом
                13 :
                begin
                  if VidFilter = 0 then
                  begin
                    WasEq := FALSE;
                    MenuSelected2 := 1;
                    pc.UseMenu;
                    GameState := gsUSEMENU;
                  end else
                    begin
                      UseItem(InvList[MenuSelected]);
                      GameState := gsPLAY;
                    end;
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
          end ELSE

          // Список действий над предметом
          if GameState = gsUSEMENU then
          begin
            case Key of
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
                      UseItem(MenuSelected);
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
          end ELSE

          // Меню навыков и способностей
          if GameState = gsSKILLSMENU then
          begin
            case Key of
              // Вверх
              38,104,56 :
              begin
                if MenuSelected = 1 then MenuSelected := 4 else dec(MenuSelected);
                OnPaint(SENDER);
              end;
              // Вниз
              40,98,50 :
              begin
                if MenuSelected = 4 then MenuSelected := 1 else inc(MenuSelected);
                OnPaint(SENDER);
              end;
              // Ok...
              13 :
              begin
                case MenuSelected of
                  3 : // Особенные способности
                  GameState := gsWPNSKILLS;
                  4 : // Особенные способности
                  GameState := gsABILITYS;
                end;
                MenuSelected := 1;
                OnPaint(Sender);
              end;
            end;
          end; {ELSE}
          
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
    GameState := gsHEROATR;
    OnPaint(Sender);
    Key := #0;
  end;
end;

{ Это нужно что бы TAB обработать }
procedure TMainForm.CMDialogKey(var msg: TCMDialogKey);
begin
  if msg.Charcode <> VK_TAB then inherited;
end;

{ Начальные данные }
procedure TMainForm.InitGame;
begin
  GameState := gsPLAY;
  AskForQuit := TRUE;
  M.MakeSpMap(1);
  pc.PlaceHere(6,18);
  pc.FOV;
  Addmsg('{Очень теплый и ясный день.}');
  Addmsg('После нескольких недель странствия, ты, наконец, прибыл'+pc.HeSheIt(1)+' в деревушку Эвилиар.');
  Addmsg('Ходят слухи, что здесь творятся странные вещи. Ты хочешь разобраться в этом.');
  Addmsg(' ');
  Addmsg('Нажми ([F1]), если нужна помощь.');
  OnPaint(NIL);
end;

end.
