// ������������ Wander
unit conf;

interface

var
  // �������� �������
  FontMap: String = 'FixedSys'; 
  FontMsg: String = 'FixedSys';
  FontSize: Byte = 10;
  FontStyle: Byte = 0;
  // ������ �������
  CharX: Byte = 8;
  CharY: Byte = 16;
  // �������� �������� ������
  FlySpeed: Byte = 70;
  // ����
  Path: String;
  // ����� ����
  PlayMode: Byte = 0;
  // ������� �������� �� @
  ShowPCBar: Byte = 1;
  // ������. ������� �� ������ ������
  ShowBars: Byte = 1;

implementation

uses IniFiles, Cons;

var
  Ini: TINIFile;

initialization
  // ����
  GetDir(0, Path);
  Path := Path + '\';
  // ������ ��������� �� Wander.ini
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
