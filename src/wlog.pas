unit wlog;

interface

procedure Log(const Msg: string); overload;

implementation

uses SysUtils, Classes;

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
end;

procedure Log(const Msg: string); overload;
begin
  try
    L.Append(DateToStr(Date) + ' ' + TimeToStr(Time) + ': ' + Msg);
    L.SaveToFile(Path + '\wander.log');
  except end;
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
