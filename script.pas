unit script;

interface

procedure Run(Script: string); // Запускаем скрипт на выполнение

implementation

uses uPSCompiler, uPSRuntime, SysUtils, Classes, wlog, sutils, vars, utils, mbox,
  msg;

const ScriptPath = '\Data\Scripts\'; // Путь к папке со скриптами

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

{ Добавить сообщение }
procedure WanderAddMsg(S: string; Id : integer);
begin
  Msg.AddDrawMsg(S, Id);
  S := '';
end;

(* Вернуть окончание в зависимости от пола героя {/Ж} или {М/Ж} *)
function WanderGetMsg(s: string; gid : integer): string;
begin
  Result := Msg.GetMsg(s, gid);
end;

{ Вернуть переменную как строку }
function WanderGetStr(VR: String): String;
begin
  Result := V.GetStr(VR);
end;

{ Установить переменную как строку }
procedure WanderSetStr(VR, D: String);
begin
  V.SetStr(VR, D);
end;

{ Вернуть переменную как целое число }
function WanderGetInt(VR: String): Integer;
begin
  Result := V.GetInt(VR);
end;

{ Установить переменную как целое число }
procedure WanderSetInt(VR: String; A: Integer);
begin
  V.SetInt(VR, A);
end;

{ Инкременировать целочисленное значение переменной }
procedure WanderIncInt(VR: String; A: Integer);
begin
  V.Inc(VR, A);
end;

{ Декременировать целочисленное значение переменной }
procedure WanderDecInt(VR: String; A: Integer);
begin
  V.Dec(VR, A);
end;

{ Вернуть переменную как булевую }
function WanderGetBool(VR: String): Boolean;
begin
  Result := V.GetBool(VR);
end;

{ Установить переменную как булевую }
procedure WanderSetBool(VR: String; B: Boolean);
begin
  V.SetBool(VR, B);
end;

{ Присвоить значение одной переменной другой }
procedure WanderLetVar(V1, V2: String);
begin
  V.Let(V1, V2);
end;

{ Выполнение скрипта }
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
    Sender.AddDelphiFunction('procedure AddMsg(s: string; id : integer);');
    Sender.AddDelphiFunction('function GetMsg(AString: String; gender : byte): string;');
    Sender.AddDelphiFunction('procedure Run(Script: String);');
    Sender.AddDelphiFunction('function  GetStr(VR: String): String;');
    Sender.AddDelphiFunction('procedure SetStr(VR, D: String);');
    Sender.AddDelphiFunction('function  GetInt(VR: String): Integer;');
    Sender.AddDelphiFunction('procedure SetInt(VR: String; I: Integer);');
    Sender.AddDelphiFunction('procedure IncInt(VR: String; A: Integer);');
    Sender.AddDelphiFunction('procedure DecInt(VR: String; A: Integer);');
    Sender.AddDelphiFunction('function  GetBool(VR: String): Boolean;');
    Sender.AddDelphiFunction('procedure SetBool(VR: String; B: Boolean);');
    Sender.AddDelphiFunction('procedure LetVar(V1, V2: String);');
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
    // Если ошибка...
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
      // Если ошибки
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
    Exec.RegisterDelphiFunction(@WanderAddMsg,'ADDMSG',cdRegister);
    Exec.RegisterDelphiFunction(@WanderGetMsg,'GETMSG',cdRegister);
    Exec.RegisterDelphiFunction(@WanderRun,'RUN',cdRegister);
    Exec.RegisterDelphiFunction(@WanderGetStr,'GETSTR',cdRegister);
    Exec.RegisterDelphiFunction(@WanderSetStr,'SETSTR',cdRegister);
    Exec.RegisterDelphiFunction(@WanderGetInt,'GETINT',cdRegister);
    Exec.RegisterDelphiFunction(@WanderSetInt,'SETINT',cdRegister);
    Exec.RegisterDelphiFunction(@WanderIncInt,'INCINT',cdRegister);
    Exec.RegisterDelphiFunction(@WanderDecInt,'DECINT',cdRegister);
    Exec.RegisterDelphiFunction(@WanderGetBool,'GETBOOL',cdRegister);
    Exec.RegisterDelphiFunction(@WanderSetBool,'SETBOOL',cdRegister);
    Exec.RegisterDelphiFunction(@WanderLetVar,'LETVAR',cdRegister);
    // Выполняем скрипт
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
  // Путь
  GetDir(0, Path);
  Path := Path + ScriptPath;
  // Списки
  L := TStringList.Create;
  F := TStringList.Create;
  D := TStringList.Create;
  H := TStringList.Create;
  // Заголовочный скрипт
  H.LoadFromFile(Path + 'utils.pas');

finalization
  // Осв. ресурсы
  F.Free;
  H.Free;
  L.Free;
  D.Free;
  
end.
