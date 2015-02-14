// Конфигурация Wander
unit conf;

interface

var
  // Свойства шрифтов
  FontMap: String = 'FixedSys'; 
  FontMsg: String = 'Courier New';
  FontSize: Byte = 0;
  // Размер символа
  CharX: Byte = 8;
  CharY: Byte = 16;
  // Скорость анимации полета
  FlySpeed: Byte = 70;
  // Скорость мигания красным при ударе
  UnderHitSpeed: Byte = 10;
  // Путь
  Path: String;
  // Режим игры
  Mode: Byte = 0;
  // Полоска здоровья на @
  ShowPCBar: Byte = 1;
  // Информ. полоски на правой панели
  ShowBars: Byte = 1;
  // Далее
  MoreKey: Byte = 0;
  // Имя героя по умолчанию
  YourName: String = '';

implementation

uses IniFiles, Cons;

var
  Ini: TINIFile;

initialization
  // Путь
  GetDir(0, Path);
  Path := Path + '\';
  // Читаем настройки из Wander.ini
  Ini:= TINIFile.Create(Path + 'wander.ini');
  try
    FontMap   := Ini.ReadString('FONT', 'NameMap', 'Courier New');
    FontMsg   := Ini.ReadString('FONT', 'NameMsg', 'Courier New');
    FontSize  := Ini.ReadInteger('FONT', 'Size', 0);
    Mode      := Ini.ReadInteger('GAME', 'Mode', AdventureMode);
    FlySpeed  := Ini.ReadInteger('GAME', 'FlySpeed', 70);
    UnderHitSpeed  := Ini.ReadInteger('GAME', 'UnderHitSpeed', 10);
    ShowPCBar := Ini.ReadInteger('GAME', 'ShowPCBar', 1);
    ShowBars  := Ini.ReadInteger('GAME', 'ShowBars', 1);
    MoreKey   := Ini.ReadInteger('GAME', 'MoreKey', 0);
    YourName  := Ini.ReadString('HERO', 'YourName', '');
  finally
    Ini.Free;
  end;

finalization

end.
