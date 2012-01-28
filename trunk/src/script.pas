unit script;

interface

procedure Run(Script: string); // ��������� ������ �� ����������

implementation

uses uPSCompiler, uPSRuntime, SysUtils, Classes, wlog, sutils, vars, utils, mbox,
  msg;

const ScriptPath = '\Data\Scripts\'; // ���� � ����� �� ���������

var
  Path: string;
  L, F, H, D: TStringList;

{ ������� Rand, ��������� ����� }
function WanderRand(A, B: Integer): Integer;
begin
  Result := Utils.Rand(A, B);
end;

{ ������ WinAPI MessageBox }
procedure WanderMsgBox(Msg: String);
begin
  MBox.MsgBox(Msg);
end;

{ ��� }
procedure WanderLog(LogMsg: String);
begin
  WLog.Log(LogMsg);
end;

{ �������� ��������� }
procedure WanderAddMsg(S: string; Id : integer);
begin
  Msg.AddDrawMsg(S, Id);
  S := '';
end;

(* ������� ��������� � ����������� �� ���� ����� {/�} ��� {�/�} *)
function WanderGetMsg(s: string; gid : integer): string;
begin
  Result := Msg.GetMsg(s, gid);
end;

{ ������� ���������� ��� ������ }
function WanderGetStr(VR: String): String;
begin
  Result := V.GetStr(VR);
end;

{ ���������� ���������� ��� ������ }
procedure WanderSetStr(VR, D: String);
begin
  V.SetStr(VR, D);
end;

{ ������� ���������� ��� ����� ����� }
function WanderGetInt(VR: String): Integer;
begin
  Result := V.GetInt(VR);
end;

{ ���������� ���������� ��� ����� ����� }
procedure WanderSetInt(VR: String; A: Integer);
begin
  V.SetInt(VR, A);
end;

{ ��������������� ������������� �������� ���������� }
procedure WanderIncInt(VR: String; A: Integer);
begin
  V.Inc(VR, A);
end;

{ ��������������� ������������� �������� ���������� }
procedure WanderDecInt(VR: String; A: Integer);
begin
  V.Dec(VR, A);
end;

{ ������� ���������� ��� ������� }
function WanderGetBool(VR: String): Boolean;
begin
  Result := V.GetBool(VR);
end;

{ ���������� ���������� ��� ������� }
procedure WanderSetBool(VR: String; B: Boolean);
begin
  V.SetBool(VR, B);
end;

{ ��������� �������� ����� ���������� ������ }
procedure WanderLetVar(V1, V2: String);
begin
  V.Let(V1, V2);
end;

{ ���������� ������� }
procedure WanderRun(Script: string);
begin
  Run(Script);
end;

{ ��������� }
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

{ ��������� Run, ��������, ���������� � ���������� ������� }
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
    // ���� ������...
    S := Format('������ � �������: "%s":', [ExtractFileName(FileName)]) + #10#13;
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
      // ����� ������ �� ����...
      I := F.IndexOf(Script);
      if I > -1 then Script := D[I] else
      begin
        // ���� ��� � ����...
        F.Append(Script);
        S := Path + Script;
        if Not FileExists(S) then
        begin
          MsgBox('���� ������� "' + ExtractFileName(S) + '" �� ������!');
          Exit;
        end;
        L.LoadFromFile(S);
        Script := L.Text;
        D.Append(Script);
      end;
    end;
    // ����������� ������
    Script := H.Text + ' begin ' + Script + ' end.';
    Compiler := TPSPascalCompiler.Create;
    Compiler.OnUses := ScriptOnUses;
    if not Compiler.Compile(Script) then
    begin
      // ���� ������
      ShowScriptErrors(S);
      Compiler.Free;
      Exit;
    end;
    Compiler.GetOutput(Data);
    Compiler.Free;
    // ��������� ������
    Exec := TPSExec.Create;
    // ���������
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
    // ��������� ������
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
  // ����
  GetDir(0, Path);
  Path := Path + ScriptPath;
  // ������
  L := TStringList.Create;
  F := TStringList.Create;
  D := TStringList.Create;
  H := TStringList.Create;
  // ������������ ������
  H.LoadFromFile(Path + 'utils.pas');

finalization
  // ���. �������
  F.Free;
  H.Free;
  L.Free;
  D.Free;
  
end.
