unit File_Manager;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ImgList, Menus, ScktComp, ExtCtrls;

type
  TForm3 = class(TForm)
    ListView1: TListView;
    Edit1: TEdit;
    ImageList1: TImageList;
    PopupMenu1: TPopupMenu;
    BaixarArquivo1: TMenuItem;
    EnviarArquivo1: TMenuItem;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Label1: TLabel;
    ProgressBar1: TProgressBar;
    ProgressBar2: TProgressBar;
    Label2: TLabel;
    Timer1: TTimer;
    Atualizar1: TMenuItem;
    N1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ListView1DblClick(Sender: TObject);
    procedure BaixarArquivo1Click(Sender: TObject);
    procedure EnviarArquivo1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Atualizar1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    Socket: TCustomWinSocket;
    LocalSalvar: string;
    ArquivoEnviar: TMemoryStream;
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

uses Principal;

{$R *.dfm}

procedure TForm3.FormCreate(Sender: TObject);
begin
  Edit1.Align := alTop;
  ListView1.Align := alClient;
end;

procedure TForm3.PopupMenu1Popup(Sender: TObject);
begin
  if ListView1.ItemIndex < 0 then begin
    PopUpMenu1.Items[2].Enabled := false;
    exit;
  end;

  if ListView1.Selected.SubItems[0] = 'Arquivo' then
    PopUpMenu1.Items[2].Enabled := true
  else
    PopUpMenu1.Items[2].Enabled := false;
end;

procedure TForm3.Edit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

  try
    if Key = VK_RETURN then begin
      Socket.SendText('<|Folder|>' + Edit1.Text + '<<|');
  end except
    exit;
  end;
end;

procedure TForm3.ListView1DblClick(Sender: TObject);
begin
  if ListView1.Selected.SubItems[0] = 'Arquivo' then
    exit;

  if ListView1.Selected.Caption = '..' then begin
    Edit1.Text := ExtractFilePath(Copy(Edit1.Text, 1, Length(Edit1.Text) - 1));
    Socket.SendText('<|Folder|>' + Edit1.Text + '<<|')
  end else begin
    if Copy(edit1.Text, Length(Edit1.Text), Length(Edit1.Text)) = '\' then else
      Edit1.Text := Edit1.text + '\';

    Edit1.Text := Edit1.Text + ListView1.Selected.Caption + '\';
    Socket.SendText('<|Folder|>' + Edit1.Text + '<<|');
  end;


end;

procedure TForm3.BaixarArquivo1Click(Sender: TObject);
begin
  SaveDialog1.Filter := 'Arquivo ' + ExtractFileExt(ListView1.Selected.Caption) + '|*' + ExtractFileExt(ListView1.Selected.Caption);
  if SaveDialog1.Execute then begin
    LocalSalvar := SaveDialog1.FileName + ExtractFileExt(ListView1.Selected.Caption);
    Socket.SendText('<|DownloadFile|>' + Edit1.Text + '\' + ListView1.Selected.Caption + '<<|');
  end;
end;

procedure TForm3.EnviarArquivo1Click(Sender: TObject);
begin
  if Copy(edit1.Text, Length(Edit1.Text), Length(Edit1.Text)) = '\' then else
    Edit1.Text := Edit1.text + '\';

  if OpenDialog1.Execute then begin
    ArquivoEnviar := TMemoryStream.Create;
    ArquivoEnviar.LoadFromFile(OpenDialog1.FileName);
    Socket.SendText('<|UploadFile|>' + Edit1.Text + '\' + ExtractFileName(OpenDialog1.FileName) + '<<|');
  end;
end;

procedure TForm3.Timer1Timer(Sender: TObject);
begin
  try
    ProgressBar2.Position := ArquivoEnviar.Position;
  except
    ProgressBar2.Position := 0;
    Timer1.Enabled := false;
  end;
end;

procedure TForm3.Atualizar1Click(Sender: TObject);
begin
  try
    Socket.SendText('<|Folder|>' + Edit1.Text + '<<|');
  except
    exit;
  end;
end;

procedure TForm3.FormClose(Sender: TObject; var Action: TCloseAction);
var
  L: TListItem;
begin
  L := Form1.LV1.FindCaption(0, intToStr(Socket.Handle), false, true, false);
  try
    if L <> nil then begin
      L.SubItems.Objects[4] := nil;
      Free;
    end;
  except
    L.SubItems.Objects[4] := nil;
  end;

  Destroy;

end;

end.
