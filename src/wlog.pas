unit wlog;

interface

procedure Log(const Msg: string); overload;
procedure ShowLog();
var LogPos:byte;

implementation

uses Classes, SysUtils, main, graphics, conf, cons, utils, MemCheck, Windows;

var
  L: TStringList;
  Path: String;

const
  DivStr = '=================================================';
  ErrOutputFile = 'wander.err';
  LogFile = 'wander.log';

type
  PExceptionRecord = ^TExceptionRecord;
  TExceptionRecord =
  record
    ExceptionCode        : LongWord;
    ExceptionFlags       : LongWord;
    OuterException       : PExceptionRecord;
    ExceptionAddress     : Pointer;
    NumberParameters     : Longint;
    case {IsOsException:} Boolean of
    True:  (ExceptionInformation : array [0..14] of Longint);
    False: (ExceptAddr: Pointer; ExceptObject: Pointer);
  end;

var
  oldRTLUnwindProc: procedure; stdcall;
  writeToFile : boolean = false;


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
    L.SaveToFile(Path + '\' + LogFile);
  except end;
end;

procedure ShowLog();
var c,y: byte;
    x: word;
begin
  x := L.Count;
  c := MsgAmount - 1;
  MainForm.SetFont(FontMsg);
  Mainform.SetBgColor(0);
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

procedure MyRtlUnwind; stdcall;
var
  PER : PExceptionRecord;

  procedure DoIt;
  var             // This is done in a sub-routine because string variable is used and we want it finalized
    s : string;
    E: Exception;
    CS: TCallStack;
    t : TextFile;
  begin
    s:='--------------------------------------------------------'#13#10;
    s:=s+'New exception:'#13#10;

    if PER^.ExceptionFlags and 1=1 then      // This seems to be an indication of internal Delphi exception,
    begin                                    // thus we can access 'Exception' class
      try
        E := Exception( PER^.ExceptObject);
        if (E is Exception) then
          s:=s+'Delphi exception, type '+E.ClassName+', message: '+E.Message+#13#10;
      except
      end;
    end;

    FillCallStack(CS, 5);    // 5 last entries seem to be unusable
    s:=s+        'Exception code: '+inttostr( PER^.ExceptionCode)+#13#10+
                 'Exception flags: '+inttostr( PER^.ExceptionFlags)+#13#10+
                 'Number of parameters: '+inttostr( PER^.NumberParameters)+#13#10+
                 TextualDebugInfoForAddress(Cardinal(PER^.ExceptionAddress))+#13#10+
                 CallStackTextualRepresentation(CS, '')+#13#10;

    OutputDebugString( PChar( s));

    if writeToFile then
    begin
      try
        Assign( t, ErrOutputFile);
        Append( t);
        Writeln( t, s);
        Close( t);
      except
      end;
    end;
  end;
begin
  asm
    mov eax, dword ptr [EBP+8+13*4]         // magic numbers - works for Delphi 7
    mov PER, eax
  end;

  DoIt;
    
  asm
    mov esp, ebp
    pop ebp
    jmp oldRTLUnwindProc
  end;
end;

procedure InitExceptionLogging;
var
  f : file;
begin
  try
    Assign( f, Path + '\' + ErrOutputFile);
    Rewrite( f);
    Close( f);
    writeToFile := true;
  except
    writeToFile := false;
  end;
  oldRTLUnwindProc := RTLUnwindProc;
  RTLUnwindProc := @MyRtlUnwind;
end;

initialization
  InitExceptionLogging;
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
