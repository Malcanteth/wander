program mapper;

uses
  Forms,
  mapeditor in 'mapeditor.pas' {MainEdForm},
  cons in 'cons.pas',
  map in 'map.pas',
  tile in 'tile.pas',
  monsters in 'monsters.pas',
  player in 'player.pas',
  utils in 'utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Map Editor';
  Application.CreateForm(TMainEdForm, MainEdForm);
  MainEdForm.Caption := 'Map Editor for WANDER ' + MapEditorVersion;
  Application.Run;
end.
