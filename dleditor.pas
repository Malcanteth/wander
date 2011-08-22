unit dleditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TMainDlForm = class(TForm)
    dialoglist: TListBox;
    question: TMemo;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    GroupBox1: TGroupBox;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Memo1: TMemo;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    ListBox2: TListBox;
    Button9: TButton;
    Button10: TButton;
    CheckBox1: TCheckBox;
    GroupBox2: TGroupBox;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Memo2: TMemo;
    Button14: TButton;
    Button15: TButton;
    Button16: TButton;
    ListBox3: TListBox;
    CheckBox2: TCheckBox;
    GroupBox3: TGroupBox;
    Button17: TButton;
    Button18: TButton;
    Button19: TButton;
    Memo3: TMemo;
    Button20: TButton;
    Button21: TButton;
    Button22: TButton;
    ListBox4: TListBox;
    CheckBox3: TCheckBox;
    GroupBox4: TGroupBox;
    Button23: TButton;
    Button24: TButton;
    Button25: TButton;
    Memo4: TMemo;
    Button26: TButton;
    Button27: TButton;
    Button28: TButton;
    ListBox5: TListBox;
    CheckBox4: TCheckBox;
    GroupBox5: TGroupBox;
    Button29: TButton;
    Button30: TButton;
    Button31: TButton;
    Memo5: TMemo;
    Button32: TButton;
    Button33: TButton;
    Button34: TButton;
    ListBox6: TListBox;
    CheckBox5: TCheckBox;
    GroupBox6: TGroupBox;
    ComboBox1: TComboBox;
    Label2: TLabel;
    Edit1: TEdit;
    Label3: TLabel;
    Edit2: TEdit;
    Button35: TButton;
    GroupBox7: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    ComboBox2: TComboBox;
    Edit3: TEdit;
    Edit4: TEdit;
    Button36: TButton;
    Button37: TButton;
    DialogName: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    Button38: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button37Click(Sender: TObject);
    function SaveToFile : boolean;
    function LoadFromFile : boolean;
    procedure Button38Click(Sender: TObject);
  private
  public
  end;

const
  MaxDialogList = 255;
  MaxDialogsVariants = 30;
  MaxAnswersVariants = 5;
  MaxIf = 3;
  MaxResults = 3;

type
  TResult = record
    n : byte;           // Номер результата
    a : array[1..2] of integer;   // Значения чего-либо
  end;

  TIf = record
    n : byte;           // Номер условия
    a : array[1..2] of integer;   // Значения чего-либо
  end;

  TAnswerVariant = record
    Exist : boolean;
    Ifs : array[1..MaxIf] of TIf;
    Answer : string;
    Results : array[1..MaxResults] of TResult;
    WhatNext : byte;    // Перейти на другой вариант или закончить диалог
  end;

  TDialogVariant = record
    question : string[240]; // Монстр говорит (250 символов, 60 на 4 строчки)
    answers : array [1..MaxAnswersVariants] of TAnswerVariant;
  end;

  TDialog = record
    name : string[50];  // Название диалога
    variants : array [1..MaxDialogsVariants] of TDialogVariant;
  end;

var
  MainDlForm: TMainDlForm;
  Dialogs : array[1..MaxDialogList] of TDialog;
  NowDialog, NowVariant : byte;

implementation
          
{$R *.dfm}

uses
  Items;

{ Посчитать кол-во веток реплик в диалоге}
function DialogVariantAmount : byte;
var
  i,k : byte;
begin
  k := 0;
  for i:=1 to MaxDialogsVariants do
    if Dialogs[NowDialog].variants[i].question <> '' then
      inc(k);
  Result := k;
end;

{ Посчитать кол-во веток реплик в диалоге}
procedure RefreshDialogList;
var
  i : byte;
begin
  MainDlForm.dialoglist.Items.Clear;
  for i:=1 to MaxDialogList do
    if Dialogs[i].name <> '' then
      MainDlForm.dialoglist.Items.Add(Dialogs[i].name);
end;

procedure TMainDlForm.FormCreate(Sender: TObject);
begin
  if LoadFromFile = FALSE then ShowMessage('Ошибка при загрузке файла dialogs.dp!');
  NowDialog  := 1;
  NowVariant := 1;
  Label1.Caption := IntToStr(NowVariant)+'/'+IntToStr(DialogVariantAmount);
  RefreshDialogList;
end;

{ Сохранить в файл }
procedure TMainDlForm.Button37Click(Sender: TObject);
begin
  if SaveToFile = TRUE then ShowMessage('Файл dialogs.dp успешно сохранен!') else ShowMessage('Ошибка сохранения!');
end;

{ Сохранить в файл }
function TMainDlForm.SaveToFile : boolean;
var
  f : file;
  i,kol,m,k,x,y : byte;
begin
  CreateDir('data');
  AssignFile(f,'data/dialogs.dp');
  {$I-}
  Rewrite(f,1);
  for kol:=1 to MaxDialogList do
    if Dialogs[kol].name = '' then
      break;
  kol := kol - 1;
  BlockWrite(f, kol, SizeOf(kol));
  if kol > 0 then
    for i:=1 to kol do
    begin
      // Название диалога
      BlockWrite(f, Dialogs[i].name, SizeOf(Dialogs[i].name));
      // Записать кол-во вариантов диалога
      y := DialogVariantAmount;
      BlockWrite(f, y, SizeOf(y));
      for m:=1 to y do
      begin
        for k:=1 to MaxAnswersVariants do
          if Dialogs[i].variants[m].answers[k].Exist = FALSE then
            break;
        k := k -1;
        BlockWrite(f, k, SizeOf(k));
        if k > 0 then
          for x:=1 to k do
            BlockWrite(f, Dialogs[i].variants[m].answers[x], SizeOf(Dialogs[i].variants[m].answers[x]));
      end;
    end;
  CloseFile(f);
  {$I+}
  if IOResult <> 0 then
    Result := false else
      Result := true;
end;

{ Загрузить из файла }
function TMainDlForm.LoadFromFile : boolean;
var
  f : file;
  i,kol,m,k,x,y : byte;
begin
  AssignFile(f,'data/dialogs.dp');
  {$I-}
  Reset(f,1);
  BlockRead(f, kol, SizeOf(kol));
  if kol > 0 then
    for i:=1 to kol do
    begin
      // Название диалога
      BlockRead(f, Dialogs[i].name, SizeOf(Dialogs[i].name));
      BlockRead(f, y, SizeOf(y));
      for m:=1 to y do
      begin
        BlockRead(f, k, SizeOf(k));
        if k > 0 then
          for x:=1 to k do
            BlockRead(f, Dialogs[i].variants[m].answers[x], SizeOf(Dialogs[i].variants[m].answers[x]));
      end;
    end;
  CloseFile(f);
  {$I+}
  if IOResult <> 0 then
    Result := false else
      Result := true;
end;

{ Перенести всю информацию из компонентов в массив }
procedure TMainDlForm.Button38Click(Sender: TObject);
begin
  Dialogs[NowDialog].name := DialogName.Text;
  Dialogs[NowDialog].variants[NowVariant].question := question.Text;
  if CheckBox1.Checked then
  begin
    Dialogs[NowDialog].variants[NowVariant].answers[1].Exist := TRUE;
    Dialogs[NowDialog].variants[NowVariant].answers[1].Answer := Memo1.Text;
    Dialogs[NowDialog].variants[NowVariant].answers[1].WhatNext :=
  end;
  //
  RefreshDialogList;
end;

end.
