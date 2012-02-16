// Диалог MsgBox на WinAPI вместо тяжелого Dialogs c ShowMessage,
// не требует преобразования типов, также записывает сообщение в лог
unit MBox;

interface

uses Windows, SysUtils;

procedure MsgBox(const BoxStrMessage: String); overload;
procedure MsgBox(const BoxIntMessage: Integer); overload;
procedure MsgBox(const BoxBoolMessage: Boolean); overload;

implementation

uses wlog;

procedure MsgBox(const BoxStrMessage: String); overload;
begin
  MessageBox(0, PChar(BoxStrMessage), 'Wander', MB_OK);
  Log('Message: ' + BoxStrMessage);
end;

procedure MsgBox(const BoxIntMessage: Integer); overload;
begin
  MessageBox(0, PChar(IntToStr(BoxIntMessage)), 'Wander', MB_OK);
  Log('Message: ' + IntToStr(BoxIntMessage));
end;

procedure MsgBox(const BoxBoolMessage: Boolean); overload;
begin
  MessageBox(0, PChar(BoolToStr(BoxBoolMessage)), 'Wander', MB_OK);
  Log('Message: ' + BoolToStr(BoxBoolMessage));
end;

end.
