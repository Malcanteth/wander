unit help;

interface

uses
  Utils, Cons, Msg;

procedure ShowHelp; // Показать список команд
procedure ShowHistory; // Показать историю сообщений

implementation

uses
  Main, SysUtils, conf;

{ Показать список команд }
procedure ShowHelp;
var
  Y: Byte;

  procedure Add(S: string);
  begin
    AddTextLine(3, Y, S);
    Inc(Y);
  end;

begin
  Y := 2;
  StartDecorating('<-ПОМОЩЬ->', FALSE);
  Add('Все просто - передвигайте своего героя, используя стрелки управления и используйте команды:');
  Add('$ESC$   - Выйти из игры в меню                     $S$     - Стрелять');
  Add('$C$     - Закрыть дверь                            $O$     - Открыть');
  Add('$L$     - Смотреть                                 $X$     - Навыки и способности');
  Add('$T$     - Разговаривать                            $M$     - История сообщений');
  Add('$Q$     - Список квестов                           $TAB$   - Изменить тактику боя');
  Add('$E$     - Экипировка                               $F$     - Есть');
  Add('$I$     - Инвентарь                                $D$     - Пить');
  Add('$A$     - Атаковать                                $SPACE$ - Выйти\Ждать (*в игре*)');
  Add('$ENTER$ - Спуститься\Подняться по лестнице');
  Add('$G$     - Поднять предмет ($Shift + G$ - взять определенное количество)');
  Inc(Y, 4);

  Add('С помощью клавиш *цифровой клавиатуры* можно двигаться во всех направлениях (цифра $5$ - ждать).');
  Add('Передвигаться по диагонали так же можно зажав *ALT + стрелки*.');
  Inc(Y, 3);

  Add('Также используйте эти функциональные клавиши:');
  Add('#F1#    - Помощь (*эта страничка*)');
  Add('*F2*    - Сохранить игру и выйти {*Пока не работает*}');
  Add('#F5#    - Сделать скриншот');
  Add('#F9#    - Получить полную информацию о герое');
  Inc(Y, 4);

  Add('Команды не чувствительны к регистру и языку.');
  Inc(Y, 6);

  Add('Игру разработал Павел Дивненко aka BreakMeThunder *breakmt@mail.ru*');
  Add('Благодарность: Харука-тян, Apromix *bees@meta.ua*');
end;

{ Показать историю сообщений }
procedure ShowHistory;
var
  x, Y, c, t: Byte;
begin
  StartDecorating('<-ИСТОРИЯ ПОСЛЕДНИХ СООБЩЕНИЙ->', FALSE);
  with GScreen.Canvas do
  begin
    Brush.Color := 0;
    for Y := 1 to MaxHistory do
      if History[Y].Msg <> '' then
      begin
        c := 0;
        t := 1;
        for x := 1 to Length(History[Y].Msg) do
        begin
          // Символы начала и конца цвета
          if History[Y].Msg[x] = '$' then // желтый
          begin
            if c = 0 then
              c := 1
            else
              c := 0;
          end
          else if History[Y].Msg[x] = '*' then // красный
          begin
            if c = 0 then
              c := 2
            else
              c := 0;
          end
          else if History[Y].Msg[x] = '#' then // зеленый
          begin
            if c = 0 then
              c := 3
            else
              c := 0;
          end
          else
          begin
            // Цвет букв
            case c of
              0:
                Font.Color := MyRGB(160, 160, 160); // Серый
              1:
                Font.Color := MyRGB(255, 255, 0); // Желтый
              2:
                Font.Color := MyRGB(200, 0, 0); // Красный
              3:
                Font.Color := MyRGB(0, 200, 0); // Зеленый
            end;
            Textout((t - 1) * CharX, (2 * CharY) + ((Y - 1) * CharY), History[Y].Msg[x]);
            Inc(t);
          end;
        end;
        if History[Y].amount > 1 then
        begin
          Font.Color := MyRGB(200, 255, 255);
          Textout((Length(History[Y].Msg) + 1) * CharX, (2 * CharY) + ((Y - 1) * CharY), IntToStr(History[Y].amount) + ' раза.');
        end;
      end;
  end;
end;

end.
