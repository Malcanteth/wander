program dialogger;

uses
  Forms,
  dleditor in 'dleditor.pas' {MainDlForm},
  items in 'items.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := '�������� ��������';
  Application.CreateForm(TMainDlForm, MainDlForm);
  Application.Run;
end.
