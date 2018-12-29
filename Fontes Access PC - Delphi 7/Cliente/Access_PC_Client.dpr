{$IMAGEBASE 12348762}
{$R UAC.RES} // Solicita Permissão do Administrador do Windows
program Access_PC_Client;

uses
  Forms,
  Conectar in 'Conectar.pas' {Form1},
  Chat in 'Chat.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Access PC';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.

