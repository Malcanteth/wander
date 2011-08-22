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
  // Путь
  Path: String;
  // Режим игры
  PlayMode: Byte = 0;

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
  finally
    Ini.Free;
  end;

finalization

end.
