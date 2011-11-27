unit wlog;

interface

procedure Log(const Msg: string); overload;
procedure ShowLog();
var LogPos:byte;

implementation

uses Classes, SysUtils, main, graphics, conf, cons, utils;

var
  L: TStringList;
  Path: String;

const
  DivStr = '=================================================';

procedure OpenLog;
begin
  try
    L.Append('Лог открыт ' + DateToStr(Date) + ' ' + TimeToStr(Time) + '.');
    L.Append(DivStr);
  except end;
  LogPos := 0;
end;

procedure Log(const Msg: string); overload;
begin
  try
    L.Append(DateToStr(Date) + ' ' + TimeToStr(Time) + ': ' + Msg);
    L.SaveToFile(Path + '\wander.log');
  except end;
end;

procedure ShowLog();
var c,y: byte;
    x: word;
begin
  x := L.Count;
  c := MsgAmount - 1;
  MainForm.SetFont(FontMsg);
  for y := 1 to c do
    MainForm.DrawString(0, (MapY + y) , MyRGB(160,160,160), StringOfChar(' ',WindowX));
  if c > x then c := x;
  if LogPos+c >= x then LogPos := x - c;
  MainForm.DrawString(0, MapY , MyRGB(160,160,160), '> '+StringOfChar(' ',WindowX-2));
  for y := 1 to c do
    MainForm.DrawString(0, (MapY + y) , MyRGB(160,160,160), L[x-y-LogPos]);
end;

procedure CloseLog;
begin
  try
    L.Append(DivStr);
    L.Append('Лог закрыт ' + DateToStr(Date) + ' ' + TimeToStr(Time) + '.');
    L.SaveToFile(Path + '\wander.log');
  except end;
end;

initialization
  GetDir(0, Path);
  L := TStringList.Create;
  OpenLog;

finalization
  try
    CloseLog;
  finally
    L.Free;
  end;

end.
