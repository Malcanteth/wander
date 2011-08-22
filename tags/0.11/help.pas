unit help;

interface

uses
  Utils, Cons;

procedure ShowHelp;                 // Показать список команд

implementation

uses
  Main;

{ Показать список команд }
procedure ShowHelp;
begin
  StartDecorating('<-ПОМОЩЬ->', FALSE);
  with Screen.Canvas do
  begin
    Font.Color := cCYAN;
    TextOut(3*CharX,3*CharY, 'Все просто - передвигайте своего героя, используя стрелки управления и используйте команды:');
    Font.Color := cLIGHTGRAY;
    TextOut(3*CharX,5*CharY,  'ESC    - Выйти из игры');
    TextOut(3*CharX,6*CharY,  'C      - Закрыть дверь');
    TextOut(3*CharX,7*CharY,  'L      - Смотреть');
    TextOut(3*CharX,8*CharY,  'T      - Разговаривать');
    TextOut(3*CharX,9*CharY,  'Q      - Список квестов');
    TextOut(3*CharX,10*CharY, 'E      - Экипировка');
    TextOut(3*CharX,11*CharY, 'I      - Инвентарь');
    TextOut(3*CharX,12*CharY, 'A      - Атаковать (команда нужна при атаке невраждебных существ)');
    TextOut(3*CharX,13*CharY, 'ENTER  - Спуститься или подняться по лестнице');
    TextOut(3*CharX,14*CharY, 'G      - Поднять вещи');
    TextOut(3*CharX,15*CharY, 'S      - Осмотреться');
    TextOut(3*CharX,16*CharY, 'O      - Открыть');
    TextOut(3*CharX,17*CharY, 'X      - Способности');

    TextOut(3*CharX,20*CharY, 'F1     - Помощь (эта страничка)');
    TextOut(3*CharX,21*CharY, 'F2     - Сохранить игру и выйти          {Пока не работает}');
    TextOut(3*CharX,22*CharY, 'F5     - Сделать скриншот');

    Font.Color := cGRAY;
    TextOut(3*CharX,25*CharY, 'Команды не чувствительны к регистру и языку.');

    Font.Color := cLIGHTGRAY;
    TextOut(3*CharX,38*CharY, 'Игру разработал Павел Дивненко aka BreakMeThunder');
    Font.Color := cGRAY;
    TextOut(3*CharX,39*CharY, 'breakmt@mail.ru');
  end;

end;

end.
