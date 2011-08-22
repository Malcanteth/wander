unit cons;

interface

const
  { Общие константы игры }
  Version                  = '0.12';
  MapEditorVersion         = '0.6';

  { Константы  окна }
  FontName                 = 'FixedSys';
  WindowX                  = 100;
  WindowY                  = 42;

  { Константы карты }
  CharX                    = 8;
  CharY                    = 16;
  MapX                     = 80;
  MapY                     = 35;

  { Константы для генерации подземелья }
  MinRooms = 7;
  MaxRooms = 15;
  MinHeight = 3;
  MaxHeight = 10;
  MinWidth  = 6;
  MaxWidth  = 10;
  MaxDoors  = 3;

  MaxLadders = 4;          // Максимальное кол-во лестниц вниз на локации
  MaxDepth  = 10;          // Максимальная глубина подземелья

  TipsAmount = 5;

  tipRooms = 1;            // Квадратные комнаты (Тип тунеля #2)
  tipDestr = 2;            // Разрушенные (Тип тунеля #1)
  tipRuins = 3;            // Руины
  tipRulab = 4;            // Разрушенный лабиринт
  tipDRoom = 5;            // Разрушенные комнаты

  { Сообщения }
  MsgAmount                = 7;
  MsgLength                = WindowX;
  MaxHistory               = 38;

  { Константы основных цветов }
  cRANDOM                  = 1;
  cBLACK                   = 0;
  cBLUE                    = 9830400;
  cGREEN                   = 38400;
  cRED                     = 150;
  cCYAN                    = 14150430;
  cPURPLE                  = 5374116;
  cBROWN                   = 16512;
  cWHITE                   = 16777215;
  cGRAY                    = 8421504;
  cYELLOW                  = 65535;
  cLIGHTGRAY               = 14474460;
  cLIGHTRED                = 255;
  cLIGHTGREEN              = 65280;
  cLIGHTBLUE               = 16711680;
  cORANGE                  = 212675;

  { Состоянитя игры }
  gsPLAY                   = 1;
  gsCLOSE                  = 2;
  gsLOOK                   = 3;
  gsCHOOSEMONSTER          = 4;
  gsQUESTLIST              = 5;
  gsEQUIPMENT              = 6;
  gsINVENTORY              = 7;
  gsHELP                   = 8;
  gsUSEMENU                = 9;
  gsHERONAME               = 10;
  gsHEROGENDER             = 11;
  gsOPEN                   = 12;
  gsABILITYS               = 13;
  gsHISTORY                = 14;

  { Статусы героя}
  stHUNGRY                 = 1;
  stDRUNK                  = 2;

  { Пол }
  genMIDLE                 = 0;
  genMALE                  = 1;
  genFEMALE                = 2;

  { Квесты }
  QuestsAmount             = 3;       // 1-Хранилище,2-Ключ,3-Ключник

  { Герой }
  MaxHandle                = 27;      // Максимальное количество предметов
  EqAmount                 = 12;      // Колличество ячеек в экипировке

  { Сколько действий в списке использования предмета }
  HOWMANYVARIANTS          = 5;       //1-Использовать,2-Рассмотреть повнимательнее,3-Бросить,4-Отдать,5-Выкинуть
  
implementation

end.
