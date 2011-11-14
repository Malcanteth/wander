// Конфигурация Wander
unit conf;

interface

var
  // Свойства шрифтов
  FontMap: String = 'FixedSys'; 
  FontMsg: String = 'FixedSys';
  FontSize: Byte = 10;
  FontStyle: Byte = 0;
  // Размер символа
  CharX: Byte = 8;
  CharY: Byte = 16;
  // Скорость анимации полета
  FlySpeed: Byte = 70;
  // Путь
  Path: String;
  // Режим игры
  PlayMode: Byte = 0;
  // Полоска здоровья на @
  ShowPCBar: Byte = 1;
  // Информ. полоски на правой панели
  ShowBars: Byte = 1;

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
    FontMap   := Ini.ReadString('FONT', 'NameMap', 'FixedSys');
    FontMsg   := Ini.ReadString('FONT', 'NameMsg', 'FixedSys');
    FontSize  := Ini.ReadInteger('FONT', 'Size', 10);
    FontStyle := Ini.ReadInteger('FONT', 'Style', 0);
    PlayMode  := Ini.ReadInteger('GAME', 'Mode', AdventureMode);
    FlySpeed  := Ini.ReadInteger('GAME', 'FlySpeed', 70);
    ShowPCBar := Ini.ReadInteger('GAME', 'ShowPCBar', 1);
    ShowBars  := Ini.ReadInteger('GAME', 'ShowBars', 1);
  finally
    Ini.Free;
  end;

finalization

end.
