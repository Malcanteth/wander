unit help;

interface

uses
  Utils, Cons, Msg;

procedure ShowHelp;                 // Показать список команд
procedure ShowHistory;              // Показать историю сообщений

implementation

uses
  Main, SysUtils, conf;

{ Показать список команд }
procedure ShowHelp;
begin
  StartDecorating('<-ПОМОЩЬ->', FALSE);
  with GScreen.Canvas do
  begin
    AddTextLine(3, 2, 'Все просто - передвигайте своего героя, используя стрелки управления и используйте команды:');

    AddTextLine(3, 5,  '$ESC$   - Выйти из игры в меню                     $S$     - Стрелять');
    AddTextLine(3, 6,  '$C$     - Закрыть дверь                            $O$     - Открыть');
    AddTextLine(3, 7,  '$L$     - Смотреть                                 $X$     - Навыки и способности');
    AddTextLine(3, 8,  '$T$     - Разговаривать                            $M$     - История сообщений');
    AddTextLine(3, 9,  '$Q$     - Список квестов                           $TAB$   - Изменить тактику боя');
    AddTextLine(3, 10, '$E$     - Экипировка                               $F$     - Есть');
    AddTextLine(3, 11, '$I$     - Инвентарь                                $D$     - Пить');
    AddTextLine(3, 12, '$A$     - Атаковать                                $SPACE$ - Выйти\Ждать (*в игре*)');
    AddTextLine(3, 13, '$ENTER$ - Спуститься\Подняться по лестнице');
    AddTextLine(3, 14, '$G$     - Поднять предмет ($Shift + G$ - определенное количество)');

    AddTextLine(3, 20, '#F1#    - Помощь (эта страничка)');
    AddTextLine(3, 21, '#F2#    - Сохранить игру и выйти {Пока не работает}');
    AddTextLine(3, 22, '#F5#    - Сделать скриншот');
    AddTextLine(3, 23, '#F9#    - О герое');    

    AddTextLine(3, 30, 'Команды не чувствительны к регистру и языку.');
    AddTextLine(3, 31, 'Двигаться по диагонали так же можно зажав *ALT + стрелки*.');

    AddTextLine(3, 38, 'Игру разработал Павел Дивненко aka BreakMeThunder *breakmt@mail.ru*');
    AddTextLine(3, 39, 'Благодарность: Харука-тян, Apromix *bees@meta.ua*');
  end;
end;

{ Показать историю сообщений }
procedure ShowHistory;
var
  x,y,c,t : byte;
begin
  StartDecorating('<-ИСТОРИЯ ПОСЛЕДНИХ СООБЩЕНИЙ->', FALSE);
  with GScreen.Canvas do
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

end.
