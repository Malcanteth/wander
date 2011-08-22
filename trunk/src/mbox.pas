// Äטאכמד םא WinAPI גלוסעמ עÿזוכמדמ Dialogs c ShowMessage
unit MBox;

interface

uses Windows, SysUtils;

procedure MsgBox(const BoxStrMessage: String); overload;
procedure MsgBox(const BoxIntMessage: Integer); overload;
procedure MsgBox(const BoxBoolMessage: Boolean); overload;

implementation

procedure MsgBox(const BoxStrMessage: String); overload;
begin
  MessageBox(0, PChar(BoxStrMessage), 'Wander', MB_OK);
end;

procedure MsgBox(const BoxIntMessage: Integer); overload;
begin
  MessageBox(0, PChar(IntToStr(BoxIntMessage)), 'Wander', MB_OK);
end;

procedure MsgBox(const BoxBoolMessage: Boolean); overload;
begin
  MessageBox(0, PChar(BoolToStr(BoxBoolMessage)), 'Wander', MB_OK);
end;

end.
