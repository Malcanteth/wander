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
  with Screen.Canvas do
  begin
    Font.Color := cBLUEGREEN;
    TextOut(3*CharX,3*CharY, 'Все просто - передвигайте своего героя, используя стрелки управления и используйте команды:');
    Font.Color := cLIGHTGRAY;
    TextOut(3*CharX,5*CharY,  'ESC    - Выйти из игры');
    TextOut(3*CharX,6*CharY,  'C      - Закрыть дверь');
    TextOut(3*CharX,7*CharY,  'L      - Смотреть');
    TextOut(3*CharX,8*CharY,  'T      - Разговаривать');
    TextOut(3*CharX,9*CharY,  'Q      - Список квестов');
    TextOut(3*CharX,10*CharY, 'E      - Экипировка');
    TextOut(3*CharX,11*CharY, 'I      - Инвентарь');
    TextOut(3*CharX,12*CharY, 'A      - Атаковать');
    TextOut(3*CharX,13*CharY, 'ENTER  - Спуститься\Подняться по лестнице');
    TextOut(3*CharX,14*CharY, 'G      - Поднять вещи (Shift + G - поднять определенное количество)');
    TextOut(3*CharX,15*CharY, 'S      - Стрелять');
    TextOut(3*CharX,16*CharY, 'O      - Открыть');
    TextOut(3*CharX,17*CharY, 'X      - Навыки и способности');
    TextOut(3*CharX,18*CharY, 'M      - История сообщений');
    TextOut(3*CharX,19*CharY, 'TAB    - Изменить тактику боя');
    TextOut(3*CharX,20*CharY, 'F      - Есть');
    TextOut(3*CharX,21*CharY, 'D      - Пить');

    Font.Color := cPURPLE;
    TextOut(3*CharX,24*CharY, 'F1     - Помощь (эта страничка)');
    TextOut(3*CharX,25*CharY, 'F2     - Сохранить игру и выйти          {Пока не работает}');
    TextOut(3*CharX,26*CharY, 'F5     - Сделать скриншот');

    Font.Color := cGRAY;
    TextOut(3*CharX,28*CharY, 'Команды не чувствительны к регистру и языку.');
    TextOut(3*CharX,29*CharY, 'Двигаться по диагонали так же можно зажав ALT + стрелки.');
    Font.Color := cLIGHTGRAY;
    TextOut(3*CharX,38*CharY, 'Игру разработал Павел Дивненко aka BreakMeThunder');
    Font.Color := cGRAY;
    TextOut(3*CharX,39*CharY, 'breakmt@mail.ru');
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

end.
