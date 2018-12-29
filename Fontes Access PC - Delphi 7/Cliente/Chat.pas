{$IMAGEBASE 31554689}
unit Chat;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm2 = class(TForm)
    Memo2: TMemo;
    Memo1: TMemo;
    procedure Memo1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Memo1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses Conectar;

{$R *.dfm}

procedure TForm2.Memo1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then begin
    if Memo1.Lines.Text = '' then else begin
      Form1.CS1.Socket.SendText('<|Chat|>' + Form1.Edit4.Text + ' diz: ' + Memo1.Lines.Text + '<<|');
      Memo2.Lines.Add('Você disse: ' + Memo1.Lines.Text);
      Memo2.Lines.Add(' ');
      Memo1.Clear;
    end;
  end;
end;

procedure TForm2.Memo1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    Memo1.Lines.Clear;
end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Form1.CS1.Socket.SendText('<|CloseChat|>');
end;

end.
