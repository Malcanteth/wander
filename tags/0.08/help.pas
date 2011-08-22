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
  StartDecorating('<-ПОМОЩЬ->');
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
    TextOut(3*CharX,11*CharY, 'A      - Атаковать (команда нужна при атаке невраждебных существ)');
    TextOut(3*CharX,12*CharY, 'ENTER  - Спуститься или подняться по лестнице');
    TextOut(3*CharX,13*CharY, 'G      - Поднять вещи');
    TextOut(3*CharX,14*CharY, '?      - Помощь (эта страничка)');
    Font.Color := cGRAY;
    TextOut(3*CharX,16*CharY, 'Команды не чувствительны к регистру и языку.');
    Font.Color := cGREEN;
    TextOut(3*CharX,35*CharY, Version);
  end;
end;

end.
