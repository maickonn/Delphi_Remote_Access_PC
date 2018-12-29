unit Chat;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ScktComp, ComCtrls;


type
  TForm4 = class(TForm)
    Memo1: TMemo;
    Memo2: TMemo;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Memo1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Memo1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    Nome: string;
    Socket: TCustomWinSocket;
    { Public declarations }
  end;

var
  Form4: TForm4;

implementation

uses Principal;

{$R *.dfm}

procedure TForm4.FormClose(Sender: TObject; var Action: TCloseAction);
var
  L: TListItem;
begin
  Socket.SendText('<|CloseChat|>');
  L := Form1.LV1.FindCaption(0, IntToStr(Socket.Handle), false, true, false);
  L.SubItems.Objects[6] := nil;
  Sleep(2000);
  Destroy;
end;

procedure TForm4.Memo1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then begin
    if (Memo1.Text = '') or (Memo1.Lines.Text = #13) then else begin
      Memo2.Lines.Add('Você disse: ' + Memo1.Lines.Text);
      Memo2.Lines.Add(' ');
      Socket.SendText('<|Chat|>' + Nome + ' diz: ' + Memo1.Lines.Text + '<<|');
      Memo1.Clear;
    end;
  end;
end;

procedure TForm4.Memo1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    Memo1.Clear;
end;

end.
