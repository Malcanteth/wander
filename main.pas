unit main;

interface

uses
  Classes, Graphics, Forms, SysUtils, ExtCtrls;

type
  TMainForm = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ProcessMsg;
    procedure EndGame;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormResize(Sender: TObject);
  private
  public
  end;

var
  MainForm             : TMainForm;
  Screen               : TBitMap;              // Картинка для двойной-буфферизации
  WaitMore             : boolean;              // --Далее--
  WaitEnter            : boolean;              // Ждем нажатия Enter
  GameState            : byte;                 // Состояние игры
  Answer               : byte;                 // Ожидается ответ
  AskForQuit           : boolean;              // Подтверждение выхода
  MenuSelected,
  MenuSelected2        : byte;                 // Выбранный элемент в меню
  WasEq                : boolean;              // Перед вызовом меню действий с предметом был инвентарь или экипировка
  a                    : integer;
  wtd                  : byte;                 // Что сделать при выборе монстра

implementation

{$R *.dfm}

uses
  Cons, Utils, Msg, Player, Map, Special, Tile, Help, Items;

{ Инициализация }
procedure TMainForm.FormCreate(Sender: TObject);
begin
  // Рамеры окна
  ClientWidth := WindowX * CharX;
  ClientHeight := WindowY * CharY;
  // Создаем картинку
  Screen := TBitMap.Create;
  Screen.Width := ClientWidth;
  Screen.Height := ClientHeight;
  Screen.Canvas.Font.Name := FontName;
  // Инициализация игры
  AskForQuit := TRUE;
  Eviliar;
  pc.Prepare;
  pc.FOV;
  Addmsg('{Очень теплый и ясный день.}');
  Addmsg('После нескольких недель странствия, ты, наконец, прибыл в деревушку Эвилиар.');
  Addmsg('Ходят слухи, что здесь творятся странные вещи. Ты хочешь разобраться в этом.');
  GameState := gsPLAY;
end;

{ Отрисовка }
procedure TMainForm.FormPaint(Sender: TObject);
begin
  // Заполняем картинку черным цветом
  Screen.Canvas.Brush.Color := 0;
  Screen.Canvas.FillRect(Rect(0, 0, MainForm.ClientRect.Right, MainForm.ClientRect.Bottom));
  // Выводим
  case GameState of
    gsPLAY, gsCLOSE, gsLOOK, gsCHOOSEMONSTER:
    begin
      // Выводим карту
      M.DrawScene;
      // Выводим сообщения
      ShowMsgs;
      // Вывести информацию о герое
      pc.WriteInfo;
    end;
    gsQUESTLIST: pc.QuestList;
    gsEQUIPMENT: pc.Equipment;
    gsINVENTORY: pc.Inventory;
    gsHELP     : ShowHelp;
    gsUSEMENU  : begin if WasEq then pc.Equipment else pc.Inventory; pc.UseMenu; end;
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
      if Answer = 1 then
      begin
        // [Y/n]
        if (Key = 89) or (Key = 121) then
          Answer := 2 else
            Answer := 3;
      end else
        begin
          ClearMsg;
          pc.turn := 0;
          case GameState of
            // Во время игры
            gsPLAY:
            begin
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
                  pc.QuestList;
                  GameState := gsQUESTLIST;
                  OnPaint(Sender);
                end;
                // Экипировка 'e'
                69        :
                begin
                  MenuSelected := 1;
                  pc.Equipment;
                  GameState := gsEQUIPMENT;
                  OnPaint(Sender);
                end;
                // Инвентарь 'i'
                73        :
                if pc.ItemsAmount > 0 then
                begin
                  MenuSelected := 1;
                  pc.Inventory;
                  GameState := gsINVENTORY;
                end else
                  AddMsg('Твой инвентарь пуст!');
                // Помощь '?'
                191       :
                begin
                  ShowHelp;
                  GameState := gsHELP;
                  OnPaint(SENDER);
                end;
                // Атаковать 'a'
                65        : pc.SearchForAlive(1);
                // Поднять 'g'
                71        :
                case pc.PickUp(M.Item[pc.x,pc.y], FALSE) of
                  0 :
                  begin
                    if M.Item[pc.x,pc.y].amount = 1 then
                      AddMsg('Ты поднимаешь '+ItemsData[M.Item[pc.x,pc.y].id].name3+'.') else
                        AddMsg('Ты поднимаешь '+ItemsData[M.Item[pc.x,pc.y].id].name2+' ('+IntToStr(M.Item[pc.x,pc.y].amount)+' шт).');
                    M.Item[pc.x,pc.y].id := 0;
                  end;
                  1 : AddMsg('Здесь ничего не лежит!');
                  2 : AddMsg('Твой инвентарь полностю забит! Как такое могло случиться?! Пора бы подумать о том, чтобы выкинуть или продать некоторые вещи...');
                  3 : AddMsg('Ты не можешь нести больше... Слишком тяжело!');
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
            // Атаковать!
            gsCHOOSEMONSTER:
            begin
              case Key of
                35,97,49  :
                case wtd of
                  1 : pc.Fight(M.MonL[M.MonP[pc.x-1,pc.y+1]]);
                  2 : pc.Talk(M.MonL[M.MonP[pc.x-1,pc.y+1]]);
                  3 : if waseq then pc.GiveItem(M.MonL[M.MonP[pc.x-1,pc.y+1]], pc.Eq[MenuSelected]) else
                                        pc.GiveItem(M.MonL[M.MonP[pc.x-1,pc.y+1]], pc.Inv[MenuSelected]);
                end;
                40,98,50  :
                case wtd of
                  1 : pc.Fight(M.MonL[M.MonP[pc.x,pc.y+1]]);
                  2 : pc.Talk(M.MonL[M.MonP[pc.x,pc.y+1]]);
                  3 : if waseq then pc.GiveItem(M.MonL[M.MonP[pc.x,pc.y+1]], pc.Eq[MenuSelected]) else
                                        pc.GiveItem(M.MonL[M.MonP[pc.x,pc.y+1]], pc.Inv[MenuSelected]);
                end;
                34,99,51  :
                case wtd of
                  1 : pc.Fight(M.MonL[M.MonP[pc.x+1,pc.y+1]]);
                  2 : pc.Talk(M.MonL[M.MonP[pc.x+1,pc.y+1]]);
                  3 : if waseq then pc.GiveItem(M.MonL[M.MonP[pc.x+1,pc.y+1]], pc.Eq[MenuSelected]) else
                                        pc.GiveItem(M.MonL[M.MonP[pc.x+1,pc.y+1]], pc.Inv[MenuSelected]);
                end;
                37,100,52 :
                case wtd of
                  1 : pc.Fight(M.MonL[M.MonP[pc.x-1,pc.y]]);
                  2 : pc.Talk(M.MonL[M.MonP[pc.x-1,pc.y]]);
                  3 : if waseq then pc.GiveItem(M.MonL[M.MonP[pc.x-1,pc.y]], pc.Eq[MenuSelected]) else
                                        pc.GiveItem(M.MonL[M.MonP[pc.x-1,pc.y]], pc.Inv[MenuSelected]);
                end;
                39,102,54 :
                case wtd of
                  1 : pc.Fight(M.MonL[M.MonP[pc.x+1,pc.y]]);
                  2 : pc.Talk(M.MonL[M.MonP[pc.x+1,pc.y]]);
                  3 : if waseq then pc.GiveItem(M.MonL[M.MonP[pc.x+1,pc.y]], pc.Eq[MenuSelected]) else
                                        pc.GiveItem(M.MonL[M.MonP[pc.x+1,pc.y]], pc.Inv[MenuSelected]);
                end;
                36,103,55 :
                case wtd of
                  1 : pc.Fight(M.MonL[M.MonP[pc.x-1,pc.y-1]]);
                  2 : pc.Talk(M.MonL[M.MonP[pc.x-1,pc.y-1]]);
                  3 : if waseq then pc.GiveItem(M.MonL[M.MonP[pc.x-1,pc.y-1]], pc.Eq[MenuSelected]) else
                                        pc.GiveItem(M.MonL[M.MonP[pc.x-1,pc.y-1]], pc.Inv[MenuSelected]);
                end;
                38,104,56 :
                case wtd of
                  1 : pc.Fight(M.MonL[M.MonP[pc.x,pc.y-1]]);
                  2 : pc.Talk(M.MonL[M.MonP[pc.x,pc.y-1]]);
                  3 : if waseq then pc.GiveItem(M.MonL[M.MonP[pc.x,pc.y-1]], pc.Eq[MenuSelected]) else
                                        pc.GiveItem(M.MonL[M.MonP[pc.x,pc.y-1]], pc.Inv[MenuSelected]);
                end;
                33,105,57 :
                case wtd of
                  1 : pc.Fight(M.MonL[M.MonP[pc.x+1,pc.y-1]]);
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
            gsQUESTLIST, gsEQUIPMENT, gsINVENTORY, gsHELP:
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
                    OnPaint(Sender);
                  end;
                  // Вверх
                  38,104,56 :
                  begin
                    if MenuSelected = 1 then MenuSelected := EqAmount else dec(MenuSelected);
                    OnPaint(SENDER);
                  end;
                  // Вниз
                  40,98,50 :
                  begin
                    if MenuSelected = EqAmount then MenuSelected := 1 else inc(MenuSelected);
                    OnPaint(SENDER);
                  end;
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
                    OnPaint(Sender);
                  end;
                  // Вверх
                  38,104,56 :
                  begin
                    if MenuSelected = 1 then MenuSelected := ReturnInvAmount else dec(MenuSelected);
                    OnPaint(SENDER);
                  end;
                  // Вниз
                  40,98,50 :
                  begin
                    if MenuSelected = ReturnInvAmount then MenuSelected := 1 else inc(MenuSelected);
                    OnPaint(SENDER);
                  end;
                  // Открыть список действий с предметом
                  13 :
                  begin
                    WasEq := FALSE;
                    MenuSelected2 := 1;
                    pc.UseMenu;
                    GameState := gsUSEMENU;
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
                            if pc.eq[MenuSelected].amount = 1 then
                              AddMsg('Ты положил '+ItemsData[pc.eq[MenuSelected].id].name3+' обратно в инвентарь.') else
                                AddMsg('Ты положил '+ItemsData[pc.eq[MenuSelected].id].name2+' ('+IntToStr(M.Item[pc.x,pc.y].amount)+' шт) обратно в инвентарь.');
                            pc.eq[MenuSelected].id := 0;
                          end;
                          1 : AddMsg('<Ты положил пустоту обратно в свой инвентарь :)>');
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
                                  AddMsg('Ты пересчитал '+ItemsData[pc.Inv[MenuSelected].id].name2+'. Все верно - их ровно '+IntToStr(pc.Inv[MenuSelected].amount)+'.');
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
                                    pc.status[stHUNGRY] := pc.status[stHUNGRY] - ItemsData[pc.Inv[MenuSelected].id].defense;
                                    if pc.status[stHUNGRY] < -500 then
                                    begin
                                      AddMsg('[Ты не смог доесть '+ItemsData[pc.Inv[MenuSelected].id].name3+', потому что очень насытился... чересчур насытился...]');
                                      pc.status[stHUNGRY] := -500;
                                    end else
                                        AddMsg('[Ты съел '+ItemsData[pc.Inv[MenuSelected].id].name3+'.]');
                                    pc.DeleteInvItem(pc.Inv[MenuSelected], FALSE);
                                    pc.turn := 1;
                                  end else
                                    AddMsg('Тебе не хочется больше есть!');
                                end;
                                // Выпить
                                19:
                                begin
                                  AddMsg('Ты выпил '+ItemsData[pc.Inv[MenuSelected].id].name3+'.');
                                  // Лечение
                                  if pc.Inv[MenuSelected].id = idPOTIONCURE then
                                  begin
                                    if pc.Hp < pc.RHp then
                                    begin
                                      a := Random(15)+1;
                                      if pc.hp + a > pc.RHp then
                                        a := pc.RHp - pc.Hp;
                                      inc(pc.hp, a);
                                      if pc.Hp >= pc.RHp then
                                      begin
                                        AddMsg('[Ты полностью исцелился!] ({+'+IntToStr(a)+'})');
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
                                      AddMsg('[Ты полностью исцелился!] ({+'+IntToStr(pc.RHp-pc.Hp)+'})');
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
                                        AddMsg('Ты довольно быстро осушил бутылку пива. Не плохо. Освежает!');
                                      inc(pc.status[stDRUNK], 130);  
                                    end else
                                      AddMsg('Ты попытался выпить еще, но случайно бутылка выскользнула из твоих рук и разбилась!..');
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
                      if M.Item[pc.x,pc.y].id = 0 then
                      begin
                        if WasEq then
                        begin
                          PutItem(pc.x,pc.y, pc.Eq[MenuSelected]);
                          AddMsg('Ты выкинул '+ItemsData[pc.Eq[MenuSelected].id].name3+'.');
                          pc.DeleteInvItem(pc.Eq[MenuSelected], TRUE);
                          pc.turn := 1;
                        end else
                          begin
                            PutItem(pc.x,pc.y, pc.Inv[MenuSelected]);
                            AddMsg('Ты выкинул '+ItemsData[pc.Inv[MenuSelected].id].name3+'.');
                            pc.DeleteInvItem(pc.Inv[MenuSelected], TRUE);
                            pc.turn := 1;
                          end;
                      end else
                        AddMsg('На этом месте уже лежит другой предмет!');
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
      if (Ask('Покинуть мир, совершив суицид? [(Y/n)]')) then
      begin
        CanClose := TRUE;
        EndGame;
      end else
        AddMsg('Ты решил пожить еще чуть-чуть.');
    end else
      begin
        GameState := gsPLAY;
        OnPaint(SENDER);
      end;
end;

{ Развернуть - свернуть окно }
procedure TMainForm.FormResize(Sender: TObject);
begin
  if GameState > 0 then
    OnPaint(Sender);
end;

end.
