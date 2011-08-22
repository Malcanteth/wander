unit script;

interface

procedure Run(Script: string); // Запускаем скрипт на выполнение

implementation

uses uPSCompiler, uPSRuntime, SysUtils, Classes, wlog, sutils, vars, utils, mbox;

const ScriptPath = '\Data\Scripts\';

var
  Path: string;
  L, F, H, D: TStringList;

{ Функция Rand, случайное число }
function WanderRand(A, B: Integer): Integer;
begin
  Result := Utils.Rand(A, B);
end;

{ Диалог WinAPI MessageBox }
procedure WanderMsgBox(Msg: String);
begin
  MBox.MsgBox(Msg);
end;

{ Лог }
procedure WanderLog(LogMsg: String);
begin
  WLog.Log(LogMsg);
end;

{ Dыполнение скрипта }
procedure WanderRun(Script: string);
begin
  Run(Script);
end;

{ Заголовки }
function ScriptOnUses(Sender: TPSPascalCompiler; const Name: string): Boolean;
begin
  if Name = 'SYSTEM' then
  begin
    Sender.AddDelphiFunction('function Rand(A, B: Integer): Integer;');
    Sender.AddDelphiFunction('procedure MsgBox(S: String);');
    Sender.AddDelphiFunction('procedure Log(LogMsg: String);');
    Sender.AddDelphiFunction('procedure Run(Script: String);');
    Result := True;
  end else
    Result := False;
end;

{ Процедура Run, загрузка, компиляция и выполнение скрипта }
procedure Run(Script: string);
var
  Compiler: TPSPascalCompiler;
  Exec: TPSExec;
  S, Data: string;
  I: Integer;
  procedure ShowScriptErrors(const FileName: String);
  var
    I: Integer;
    S: string;
  begin
    S := Format('Ошибки в скрипте: "%s":', [ExtractFileName(FileName)]) + #10#13;
    for I := 0 to Compiler.MsgCount - 1 do
      S := S + Compiler.Msg[I].MessageToString + ';'#10#13;
    MsgBox(S);
  end;
begin
  try
    S := Script;
    //
    if (StrRight(S, 4) = '.pas') then
    begin
      // Берем скрипт из кеша...
      I := F.IndexOf(Script);
      if I > -1 then Script := D[I] else
      begin
        // Если нет в кеше...
        F.Append(Script);
        S := Path + Script;
        if Not FileExists(S) then
        begin
          MsgBox('Файл скрипта "' + ExtractFileName(S) + '" не найден!');
          Exit;
        end;
        L.LoadFromFile(S);
        Script := L.Text;
        D.Append(Script);
      end;
    end;
    // Компилируем скрипт
    Script := H.Text + ' begin ' + Script + ' end.';
    Compiler := TPSPascalCompiler.Create;
    Compiler.OnUses := ScriptOnUses;
    if not Compiler.Compile(Script) then
    begin
      ShowScriptErrors(S);
      Compiler.Free;
      Exit;
    end;
    Compiler.GetOutput(Data);
    Compiler.Free;
    // Выполняем скрипт
    Exec := TPSExec.Create;
    // Указатели
    Exec.RegisterDelphiFunction(@WanderRand,'RAND',cdRegister);
    Exec.RegisterDelphiFunction(@WanderLog,'LOG',cdRegister);
    Exec.RegisterDelphiFunction(@WanderMsgBox,'MSGBOX',cdRegister);
    Exec.RegisterDelphiFunction(@WanderRun,'RUN',cdRegister);
    //
    if not Exec.LoadData(Data) then
    begin
      Exec.Free;
      Exit;
    end;
    Exec.RunScript;
    Exec.Free;
  except end;
end;

initialization
  GetDir(0, Path);
  Path := Path + ScriptPath;
  L := TStringList.Create;
  F := TStringList.Create;
  D := TStringList.Create;
  H := TStringList.Create;
  H.LoadFromFile(Path + 'utils.pas');

finalization
  F.Free;
  H.Free;
  L.Free;
  D.Free;
  
end.
