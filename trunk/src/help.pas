unit help;

interface

uses
  Utils, Cons, Msg;

procedure ShowHelp;                 // Показать список команд
procedure ShowHistory;              // Показать историю сообщений
procedure DrawGameMenu;             // Игровое меню

const
  GMChooseAmount = 2;
  gmNEWGAME      = 1;
  gmEXIT         = 2;

implementation

uses
  Main, SysUtils, conf, wlog, MapEditor, mbox, player;

{ Показать список команд }
procedure ShowHelp;
begin
  StartDecorating('<-ПОМОЩЬ->', FALSE);
  with Screen.Canvas do
  begin
    AddTextLine(3, 2, 'Все просто - передвигайте своего героя стрелками управления и используйте команды:');

    AddTextLine(3, 5,  '$ESC$   - Выйти из игры в меню                      $S$     - Стрелять');
    AddTextLine(3, 6,  '$C$     - Закрыть дверь                             $O$     - Открыть');
    AddTextLine(3, 7,  '$L$     - Смотреть                                  $X$     - Навыки и способности');
    AddTextLine(3, 8,  '$T$     - Разговаривать                             $M$     - История сообщений');
    AddTextLine(3, 9,  '$Q$     - Список квестов                            $TAB$   - Изменить тактику боя');
    AddTextLine(3, 10, '$E$     - Экипировка                                $F$     - Есть');
    AddTextLine(3, 11, '$I$     - Инвентарь                                 $D$     - Пить');
    AddTextLine(3, 12, '$A$     - Атаковать');
    AddTextLine(3, 13, '$ENTER$ - Спуститься\Подняться по лестнице');
    AddTextLine(3, 14, '$G$     - Поднять вещи ($Shift + G$ - определенное количество)');

    AddTextLine(3, 20, '#F1#    - Помощь (эта страничка)');
    AddTextLine(3, 21, '#F2#    - Сохранить игру и выйти {Пока не работает}');
    AddTextLine(3, 22, '#F5#    - Сделать скриншот');

    if Debug then AddTextLine(3, 26, '#~#     - Вызвать\Спрятать консоль');

    AddTextLine(3, 39, 'Команды не чувствительны к регистру и языку.');
    AddTextLine(3, 30, 'Двигаться по диагонали так же можно зажав *ALT + стрелки*.');

    AddTextLine(3, 39, 'Игру разработал Павел Дивненко aka BreakMeThunder *breakmt@mail.ru*');
  end;
end;

{ Показать историю сообщений }
procedure ShowHistory;
var
  x,y,c,t : byte;
begin
  StartDecorating('<-ИСТОРИЯ ПОСЛЕДНИХ СООБЩЕНИЙ->', FALSE);
  with Screen.Canvas do
  begin
    Brush.Color := 0;
    for y:=1 to MaxHistory do
      if History[y].Msg <> '' then
      begin
        c := 0;
        t := 1;
        for x:=1 to Length(History[y].msg) do
        begin
          //Символы начала и конца цвета
          if History[y].msg[x] = '$' then  // желтый
          begin
            if c = 0 then c := 1 else c := 0;
          end else
          if History[y].msg[x] = '*' then  // красный
          begin
            if c= 0 then c := 2 else c := 0;
          end else
          if History[y].msg[x] = '#' then  // зеленый
          begin
            if c= 0 then c := 3 else c := 0;
          end else
            begin
              //Цвет букв
              case c of
                0 : Font.Color := MyRGB(160,160,160);  //Серый
                1 : Font.Color := MyRGB(255,255,0);    //Желтый
                2 : Font.Color := MyRGB(200,0,0);      //Красный
                3 : Font.Color := MyRGB(0,200,0);      //Зеленый
              end;
              Textout((t-1)*CharX, (2*CharY)+((y-1)*CharY), History[y].msg[x]);
              inc(t);
            end;
        end;
        if History[y].amount > 1 then
        begin
          Font.Color := MyRGB(200,255,255);
          Textout((Length(History[y].msg)+1)*CharX, (2*CharY)+((y-1)*CharY), IntToStr(History[y].amount)+' раза.');
        end;
      end;
  end;
end;

{ Игровое меню }
procedure DrawGameMenu;
const
  TableX = 39;
  TableW = 20;
  MenuNames : array[1..GMChooseAmount] of string =
  ('Новая игра', 'Выход');
var
  i,j: byte;
begin
  if (GameState = gsPlay) then BlackWhite(Screen);
  DrawBorder(TableX, Round(WindowY/2)-Round((GMChooseAmount+2)/2)-2, TableW,(GMChooseAmount+2)+1,crBLUEGREEN);
  GameMenu := TRUE;
  with TMenu.Create(TableX+2, (WindowY div 2)-(GMChooseAmount+2)div 2) do
  begin
    for i:=1 to GMChooseAmount do
      Add(MenuNames[i]);
    j := 1;
    repeat
      j:=Run(Selected);
    until ((j = 0) and (GameState <> gsINTRO))or(j<>0);
    Free;
  end;
  GameMenu := FALSE;  
  if j = 0 then exit;
  case j of
    gmNEWGAME :
    begin
      if Mode = 0 then
        pc.ChooseMode
      else
      begin
        PlayMode := Mode;
        // Если режим приключений то нужно загрузить карты
        if PlayMode = AdventureMode then
        if not MainEdForm.LoadSpecialMaps then
        begin
          MsgBox('Ошибка загрузки карт!');
          Halt;
        end;
        ChangeGameState(gsHERORANDOM);
        end;
      end;
    gmEXIT    :
      begin
        GameMenu := FALSE;
        if GameState = gsINTRO then AskForQuit := FALSE;
        MainForm.Close;
      end;
    end;
end;

end.
