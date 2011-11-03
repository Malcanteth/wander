unit main;

interface

uses
  Windows, Classes, Graphics, Forms, SysUtils, ExtCtrls, Controls, StdCtrls, Dialogs, Math;

type
  TMainForm = class(TForm)
    GameTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ProcessMsg;
    procedure EndGame;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormResize(Sender: TObject);
    procedure InitGame;
    procedure GameTimerTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    procedure CMDialogKey( Var msg: TCMDialogKey );
    message CM_DIALOGKEY;
    procedure AnimFly(x1,y1,x2,y2:integer;symbol:string; color:byte);
    function GetCharFromVirtualKey(Key: Word): string;
  public
  end;

var
  MainForm             : TMainForm;
  Screen               : TBitMap;              // Картинка для двойной-буфферизации
  WaitMore             : boolean;              // --Далее--
  WaitEnter            : boolean;              // Ждем нажатия Enter
  Inputing             : boolean;              // Режим ввода
  GameState            : byte;                 // Состояние игры
  GameVersion          : string;               // Версия игры
  Answer               : string[1];            // Ожидается ответ
  AskForQuit           : boolean;              // Подтверждение выхода
  MenuSelected,
  MenuSelected2        : byte;                 // Выбранный элемент в меню
  VidFilter            : byte;                 // Предметы какого вида отоброжать в инвентаре (0-все)
  WasEq                : boolean;              // Перед вызовом меню действий с предметом был инвентарь или экипировка
  a                    : integer;
  wtd                  : byte;                 // Что сделать при выборе монстра
  DC                   : HDC;                  // Контекст устройства

implementation

{$R *.dfm}

uses
  Cons, Utils, Msg, Player, Map, Tile, Help, Items, Ability, MapEditor, Liquid,
  conf, sutils, script, mbox, vars;

{ Инициализация }
procedure TMainForm.FormCreate(Sender: TObject);
begin
  // контекст главной формы
  DC := GetDC(MainForm.Handle);
  // Рамеры окна
  ClientWidth := WindowX * CharX;
  ClientHeight := WindowY * CharY;
  with Screen do
  begin
    Width := ClientWidth;
    Height := ClientHeight;
  end;
  // Если режим приключений то нужно загрузить карты
  if PlayMode = AdventureMode then
    if not MainEdForm.LoadSpecialMaps then
    begin
      MsgBox('Ошибка загрузки карт!');
      Halt;
    end;
  GameTimer.Enabled := False;  
  GameState := gsINTRO;
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
    gsHERORANDOM   : pc.HeroRandom;
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
  // Ввод
  if Inputing then
  begin
    GameTimer.Interval := 200;
    GameTimer.Enabled := True;  // Запускаем таймер, чтобы мигал курсор
    ShowInput;                  // Показываем поле для ввода имени персонажа
  end;
  // Отображаем растягиваемый буфер
  SetStretchBltMode(Screen.Canvas.Handle, STRETCH_DELETESCANS);
  StretchBlt(DC, 0, 0, MainForm.ClientRect.Right, MainForm.ClientRect.Bottom,
         Screen.Canvas.Handle, 0, 0, Screen.Width, Screen.Height, SRCCopy);
end;

{ Нажатие на клавиши }
procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i : integer;
  n : string;
  Item : TItem;
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
        if Key = 13 then
        begin
          WaitENTER := False;          // Ввод имени закончен. Мигание курсора 
          GameTimer.Enabled := False;  // больше не нужно, отключаем таймер
        end else
        // Ввод
        if Inputing then
        begin
          if (Key = VK_BACK) and (InputPos > 0) then
          begin
            Delete(InputString,InputPos,1);
            dec(InputPos);
          end
          else if (Key = VK_DELETE) and (InputPos < Length(InputString)) then
          begin
            Delete(InputString,InputPos+1,1);
          end
          else if Key = VK_HOME then
            InputPos := 0
          else if Key = VK_END then
            InputPos := length(InputString)
          else if (Key = VK_LEFT) and (InputPos > 0) then
            dec(InputPos)
          else if (Key = VK_RIGHT) and (InputPos < Length(InputString)) then
            inc(InputPos)
          else if length(InputString)<13 then
          begin
            n := GetCharFromVirtualKey(Key);
            if n<>'' then
            begin
              if ord(n[1]) > 31 then
              begin
                Insert(n, InputString, InputPos+1);
                Inc(InputPos);
              end;
            end;
          end;
          OnPaint(Sender);
        end;
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
              13, 32 : GameState := gsHERORANDOM;
              67     : if PlayMode = 0 then PlayMode := 1 else PlayMode := 0;
            end;
          end;
          // Рандомный герой?
          gsHERORANDOM:
          begin
            pc.ClearPlayer;
            case Key of
              // Вверх/Вниз
              38,104,56,40,98,50 :
              begin
                if MenuSelected = 1 then MenuSelected := 2 else MenuSelected := 1;
                OnPaint(SENDER);
              end;
              // Ok...
              13 :
              begin
                if MenuSelected = 1 then
                  GameState := gsHEROGENDER else
                    // Всё рандомно
                    begin
                      // пол
                      pc.gender := Rand(1, 2);
                      // имя
                      case pc.gender of
                        genMALE   : pc.name := GenerateName(FALSE);
                        genFEMALE : pc.name := GenerateName(TRUE);
                      end;
                      // атрибуты
                      pc.atr[1] := Rand(1, 3);
                      pc.atr[2] := Rand(1, 3);
                      // Добавить очки умений исходя из класса
                      pc.Prepare;
                      pc.PrepareSkills;
                      if (pc.HowManyBestWPNCL > 1) and not ((pc.HowManyBestWPNCL < 3) and (pc.OneOfTheBestWPNCL(CLOSE_TWO))) then
                      begin
                        pc.CreateClWList;
                        c_choose := Wlist[Random(wlistsize)+1];
                      end;
                      if (pc.HowManyBestWPNFR > 1) and not ((pc.HowManyBestWPNFR < 3) and (pc.OneOfTheBestWPNFR(FAR_THROW))) then
                      begin
                        pc.CreateFrWList;
                        f_choose := Wlist[Random(wlistsize)+1];
                      end;
                      GameState := gsHEROCRRESULT;
                    end;
                OnPaint(Sender);
              end;
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
                if MenuSelected < 3 then pc.gender := MenuSelected else pc.gender := Rand(1, 2);
                MenuSelected := 1;
                MenuSelected2 := 1;
                pc.startheroname;
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
                if MenuSelected > 1 then dec(MenuSelected) else MenuSelected := wlistsize;
                OnPaint(SENDER);
              end;
              // Вниз
              40,98,50 :
              begin
                if MenuSelected < wlistsize then inc(MenuSelected) else MenuSelected := 1;
                OnPaint(SENDER);
              end;
              // Ok...
              13 :
              begin
                c_choose := Wlist[MenuSelected];
                MenuSelected := 1;
                MenuSelected2 := 1;
                if (pc.HowManyBestWPNFR > 1) and not ((pc.HowManyBestWPNFR < 3) and (pc.OneOfTheBestWPNFR(FAR_THROW)))  then
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
                    if (pc.HowManyBestWPNCL > 1) and not ((pc.HowManyBestWPNCL < 3) and (pc.OneOfTheBestWPNCL(CLOSE_TWO))) then
                      GameState := gsHEROCLWPN else
                        if (pc.HowManyBestWPNFR > 1) and not ((pc.HowManyBestWPNFR < 3) and (pc.OneOfTheBestWPNFR(FAR_THROW))) then
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
                GameState := gsHERORANDOM;
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
              35,97,49     : if ssShift in Shift then pc.Run(-1,1) else pc.Move(-1,1);
              40,98,50     : if ssShift in Shift then pc.Run(0,1) else pc.Move(0,1);
              34,99,51     : if ssShift in Shift then pc.Run(1,1) else pc.Move(1,1);
              37,100,52    : if ssShift in Shift then pc.Run(-1,0) else pc.Move(-1,0);
              12,101,53,32 : pc.Move(0,0);
              39,102,54    : if ssShift in Shift then pc.Run(1,0) else pc.Move(1,0);
              36,103,55    : if ssShift in Shift then pc.Run(-1,-1) else pc.Move(-1,-1);
              38,104,56    : if ssShift in Shift then pc.Run(0,-1) else pc.Move(0,-1);
              33,105,57    : if ssShift in Shift then pc.Run(1,-1) else pc.Move(1,-1);
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
                  AddMsg('У тебя нет ничего съестного!',0);
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
                  AddMsg('В инвентаре нет ничего, что можно выпить!',0);
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
                  AddMsg('Твой инвентарь пуст!',0);
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
              begin
                i := 1;
                if M.Item[pc.x,pc.y].amount > 1 then
                begin
                  // Если золото, то взять все без вопросов
                  if not (ssShift in Shift) then
                    i := M.Item[pc.x,pc.y].amount else
                      begin
                        AddMsg(ItemName(M.Item[pc.x,pc.y], 0, TRUE)+'. Сколько хочешь взять?',0);
                        n := Input(LastMsgL+1, MapY+(LastMsgY-1), IntToStr(M.Item[pc.x,pc.y].amount));
                        if TryStrToInt(n,i) then
                        begin
                          if (i > M.Item[pc.x,pc.y].amount) then
                          begin
                            AddMsg('Введено слишком большое значение.',0);
                            i := 0;
                          end;
                        end else
                          begin
                            AddMsg('Нужно ввести число.',0);
                            i := 0;
                          end;
                      end;
                end;
                if i > 0 then
                begin
                  case pc.PickUp(M.Item[pc.x,pc.y], FALSE,i) of
                    0 :
                    begin
                      Item := M.Item[pc.x,pc.y];
                      Item.amount := i;
                      AddMsg('Ты поднимаешь '+ItemName(Item,0,TRUE)+'.',0);
                      if M.Item[pc.x,pc.y].amount > i then
                        dec(M.Item[pc.x,pc.y].amount,i) else
                          M.Item[pc.x,pc.y].id := 0;
                    end;
                    1 : AddMsg('Здесь ничего не лежит!',0);
                    2 : AddMsg('Твой инвентарь полностью забит! Как такое могло случиться?! Пора бы подумать о том, чтобы выкинуть или продать некоторые вещи...',0);
                    3 : AddMsg('Ты не можешь нести больше... Слишком тяжело!',0);
                  end;
                end;
              end;
              // Открыть 'o'
              79        :
              begin
                AddMsg('Что ты хочешь открыть?',0);
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
              // Крикнуть 'y'
              89        :
              begin
                AddMsg('Что ты хочешь крикнуть?',0);
                Input(LastMsgL+1, MapY+(LastMsgY-1), '');
              end;
              // Стрелять 's'
              83       :
              begin
                if (pc.eq[13].id > 0) then
                begin
                  if (pc.eq[7].id = 0) or (ItemsData[pc.eq[7].id].kind = ItemsData[pc.eq[13].id].kind) then
                  begin
                    AddMsg('$Целиться в:$',0);
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
                      begin
                        lx := pc.x;
                        ly := pc.y;
                        pc.AnalysePlace(lx,ly,1);
                        GameState := gsAIM;
                      end;
                  end else
                    AddMsg(ItemsData[pc.eq[13].id].name2+' и '+ItemsData[pc.eq[7].id].name1+' - не совместимы!',0);
                end else
                  AddMsg('Слот амуниции в экипировке пуст!',0);
              end;
              // Поменять тактику 'tab'
              VK_TAB    :
              begin
                case pc.tactic of
                   0 : AddMsg('Текущая тактика - $Стандартная$.',0);
                   1 : AddMsg('Текущая тактика - *Агрессивное нападение*.',0);
                   2 : AddMsg('Текущая тактика - #Защита#.',0);
                end;
                case Ask('Выбрать тактику: (#A#) - Агрессивное нападение, (#S#) - Стандартная, (#D#) - Защищаться.') of
                  'A' :
                  begin
                    ClearMsg;
                    pc.tactic := 1;
                    AddMsg('Выбрано агрессивное нападение.',0);
                    AddMsg('Распределение шансов:',0);
                    AddMsg('#+50% к успешному попадению и урону#, *-50% к уклонению и эффективности брони*.',0);
                  end;
                  'S' :
                  begin
                    ClearMsg;
                    pc.tactic := 0;
                    AddMsg('Выбрана стандартная тактика.',0);
                    AddMsg('Никаких плюсов и минусов во время боя.',0);
                  end;
                  'D' :
                  begin
                    ClearMsg;
                    pc.tactic := 2;
                    AddMsg('Выбрана защитная тактика.',0);
                    AddMsg('Распределение шансов:',0);
                    AddMsg('*-50% к успешному попадению и урону*, #+50% к уклонению и эффективности брони#.',0);
                  end;
                  ELSE
                    AddMsg('Ты решил{/a} не менять тактику.',0);
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
                AddDrawMsg('Указано неправильное направление!',0);
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
                AddDrawMsg('Указано неправильное направление!',0);
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
                AddDrawMsg('Указано неправильное направление!',0);
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
              13        : AnimFly(pc.x,pc.y,lx,ly,'`',crBrown);
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
              13,83     :
                if (lx = pc.x) and (ly = pc.y) then
                  AddMsg('Проще нажми ESC, если уж так хочешь умереть!',0) else
                  begin
                    GameState := gsPLAY;
                    AnimFly(pc.x,pc.y,lx,ly, ItemTypeData[ItemsData[pc.Eq[13].id].vid].symbol, ItemsData[pc.Eq[13].id].color);
                    pc.turn := 1;
                  end;
              ELSE
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
                      case pc.PickUp(pc.eq[MenuSelected], TRUE,pc.eq[MenuSelected].amount) of
                        0 :
                        begin
                          ItemOnOff(pc.eq[MenuSelected], FALSE);
                          AddMsg('Ты положил{/a} '+ItemName(pc.eq[MenuSelected], 1, TRUE)+' обратно в инвентарь.',0);
                          pc.eq[MenuSelected].id := 0;
                        end;
                        1 : AddMsg('*Ты положил{/a} пустоту обратно в свой инвентарь :)*',0);
                        2 : AddMsg('Твой инвентарь полностью забит! Так что тебе придется нести это в руках.',0);
                        3 : AddMsg('*Этого быть не должно - даже если у тебя перегрузка, ты можешь положить то, что ты уже несешь в инвентарь.*',0);
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
                      i := 1;
                      if pc.Eq[MenuSelected].amount > 1 then
                      begin
                        AddMsg(ItemName(pc.Eq[MenuSelected], 0, TRUE)+'. Сколько хочешь выкинуть?',0);
                        n := Input(LastMsgL+1, MapY+(LastMsgY-1), IntToStr(pc.Eq[MenuSelected].amount));
                        if TryStrToInt(n,i) then
                        begin
                          if (i > pc.Eq[MenuSelected].amount) then
                          begin
                            AddMsg('Введено слишком большое значение.',0);
                            i := 0;
                          end;
                        end else
                          begin
                            AddMsg('Нужно ввести число.',0);
                            i := 0;
                          end;
                      end;
                      if i > 0 then
                      begin
                        if PutItem(pc.x,pc.y, pc.Eq[MenuSelected], i) then
                        begin
                          Item := pc.Eq[MenuSelected];
                          Item.amount := i;
                          AddMsg('Ты выкидываешь '+ItemName(Item,0,TRUE)+'.',0);
                          pc.DeleteInvItem(pc.Eq[MenuSelected], i);
                          pc.turn := 1;
                        end else
                          AddMsg('Здесь нет места для того, что бы выкинуть что-либо!',0);
                      end;
                    end else
                      begin
                        i := 1;
                        if pc.Inv[MenuSelected].amount > 1 then
                        begin
                          AddMsg(ItemName(pc.Inv[MenuSelected], 0, TRUE)+'. Сколько хочешь выкинуть?',0);
                          n := Input(LastMsgL+1, MapY+(LastMsgY-1), IntToStr(pc.Inv[MenuSelected].amount));
                          if TryStrToInt(n,i) then
                          begin
                            if (i > pc.Inv[MenuSelected].amount) then
                            begin
                              AddMsg('Введено слишком большое значение.',0);
                              i := 0;
                            end;
                          end else
                            begin
                              AddMsg('Нужно ввести число.',0);
                              i := 0;
                            end;
                        end;
                        if i > 0 then
                        begin
                          if PutItem(pc.x,pc.y, pc.Inv[MenuSelected], i) then
                          begin
                            Item := pc.Inv[MenuSelected];
                            Item.amount := i;
                            AddMsg('Ты выкидываешь '+ItemName(Item,0,TRUE)+'.',0);
                            pc.DeleteInvItem(pc.Inv[MenuSelected], i);
                            pc.turn := 1;
                          end else
                            AddMsg('Здесь нет места для того, что бы выкинуть что-либо!',0);
                        end;
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
      if (Ask('Покинуть мир, совершив суицид? #(Y/n)#')) = 'Y' then
      begin
        CanClose := TRUE;
        EndGame;
      end else
        AddMsg('Ты решил{/a} пожить еще чуть-чуть.',0);
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

{ Это нужно, что бы TAB обработать }
procedure TMainForm.CMDialogKey(var msg: TCMDialogKey);
begin
  if msg.Charcode <> VK_TAB then inherited;
end;

{ Начальные данные }
procedure TMainForm.InitGame;
begin
  GameState := gsPLAY;
  AskForQuit := TRUE;
  // Цвета и состояния напитков
  GenerateColorAndStateOfLiquids;
  // Выбор режима приключения
  V.SetInt('PlayMode', PlayMode);
  case PlayMode of
    AdventureMode:  // Деревушка Эвилиар
    begin
      pc.level := 1;
      M.MakeSpMap(pc.level);
      pc.PlaceHere(6,18);
      Run('InitStory.pas');
    end;
    DungeonMode:    // Вход в подземелье
    begin
      pc.level := 7;
      M.MakeSpMap(pc.level);
      pc.PlaceHere(42,16);
      Run('InitStory.pas');
    end;
  end;
  pc.FOV;
  Addmsg(' ',0);
  Addmsg('Нажми (#F1#), если нужна помощь.',0);
  OnPaint(NIL);
end;

{ Анимация летящего объекта }
procedure TMainForm.AnimFly(x1,y1,x2,y2:integer; symbol:string; color:byte);
var
  dx,dy,i,sx,sy,check,e,oldx,oldy:integer;
begin
  dx:=abs(x1-x2);
  dy:=abs(y1-y2);
  sx:=Sign(x2-x1);
  sy:=Sign(y2-y1);
  FlyX:=x1;
  FlyY:=y1;
  FlyS:=symbol;
  FlyC:=color;
  check:=0;
  if dy>dx then begin
      dx:=dx+dy;
      dy:=dx-dy;
      dx:=dx-dy;
      check:=1;
  end;
  e:= 2*dy - dx;
  for i:=0 to dx-1 do
  begin
    oldx := FlyX;
    oldy := FlyY;
    if e>=0 then
    begin
      if check=1 then FlyX:=FlyX+sx else FlyY:=FlyY+sy;
      e:=e-2*dx;
    end;
    if check=1 then FlyY:=FlyY+sy else FlyX:=FlyX+sx;
    e:=e+2*dy;
    OnPaint(NIL);
    sleep(FlySpeed);
    // А теперь проверить с чем столкнулось
    if not TilesData[M.Tile[FlyX,FlyY]].void then
    begin
      // Надо придумать какое сообщение здесь вывести
      break;
    end else
      // Стоит монстр
      if M.MonP[FlyX,FlyY] > 0 then
      begin
        autoaim := M.MonP[FlyY,FlyY];
        pc.Fire(M.MonL[M.MonP[FlyX,FlyY]]);
          break;
      end;
  end;
  pc.DecArrows;
  FlyX := 0;
  FlyY := 0;
end;

{ Word 2 Char }
function TMainForm.GetCharFromVirtualKey(Key: Word): string;
var
  keyboardState: TKeyboardState;
  asciiResult: Integer;
begin
  GetKeyboardState(keyboardState) ;
  SetLength(Result, 2) ;
  asciiResult := ToAscii(key, MapVirtualKey(key, 0), keyboardState, @Result[1], 0) ;
  case asciiResult of
    0: Result := '';
    1: SetLength(Result, 1) ;
    2:;
  else
    Result := '';
end;

end;

procedure TMainForm.GameTimerTimer(Sender: TObject);
begin
  MainForm.Paint;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  ReleaseDC(MainForm.Handle, DC);
  DeleteDC(DC);
end;

initialization
  Randomize;
  // Создаем картинку (буфер)
  Screen := TBitMap.Create;
  // Разумные границы
  if (FontSize < 8 ) then FontSize := 8;
  if (FontSize > 20) then FontSize := 20;
  // Свойства шрифта
  with Screen.Canvas do
  begin
    Font.Name := FontMsg;
    Font.Size := FontSize;
    case FontStyle of
      1:   Font.Style := [fsBold];
      2:   Font.Style := [fsItalic];
      3:   Font.Style := [fsBold, fsItalic];
      else Font.Style := [];
    end;
    CharX := TextWidth('W');
    CharY := TextHeight('W');
  end;

finalization
  // Освобождаем картинку (буфер)
  Screen.Free;

end.
