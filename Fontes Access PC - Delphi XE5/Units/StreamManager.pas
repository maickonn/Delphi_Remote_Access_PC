unit StreamManager;

interface

uses
  Windows, Classes, Graphics;

procedure GetScreenToBmp(DrawCur: Boolean; StreamName: TMemoryStream);
procedure CompareStream(MyFirstStream, MySecondStream, MyCompareStream
  : TMemoryStream);
procedure ResumeStream(MyFirstStream, MySecondStream, MyCompareStream
  : TMemoryStream);

implementation

// Captura a tela
procedure GetScreenToBmp(DrawCur: Boolean; StreamName: TMemoryStream);
var
  Mybmp: Tbitmap;
  Cursorx, Cursory: integer;
  dc: hdc;
  Mycan: Tcanvas;
  R: TRect;
  DrawPos: TPoint;
  MyCursor: TIcon;
  hld: hwnd;
  Threadld: dword;
  mp: TPoint;
  pIconInfo: TIconInfo;
begin
  Mybmp := Tbitmap.Create;
  Mycan := Tcanvas.Create;
  dc := GetWindowDC(0);
  try
    Mycan.Handle := dc;
    R := Rect(0, 0, GetSystemMetrics(SM_CXSCREEN),
      GetSystemMetrics(SM_CYSCREEN));
    Mybmp.Width := R.Right;
    Mybmp.Height := R.Bottom;
    Mybmp.Canvas.CopyRect(R, Mycan, R);
  finally
    releaseDC(0, dc);
  end;
  Mycan.Handle := 0;
  Mycan.Free;

  if DrawCur then
  begin
    GetCursorPos(DrawPos);
    MyCursor := TIcon.Create;
    GetCursorPos(mp);
    hld := WindowFromPoint(mp);
    Threadld := GetWindowThreadProcessId(hld, nil);
    AttachThreadInput(GetCurrentThreadId, Threadld, True);
    MyCursor.Handle := Getcursor();
    AttachThreadInput(GetCurrentThreadId, Threadld, False);
    GetIconInfo(MyCursor.Handle, pIconInfo);
    Cursorx := DrawPos.x - round(pIconInfo.xHotspot);
    Cursory := DrawPos.y - round(pIconInfo.yHotspot);
    Mybmp.Canvas.Draw(Cursorx, Cursory, MyCursor);
    DeleteObject(pIconInfo.hbmColor);
    DeleteObject(pIconInfo.hbmMask);
    MyCursor.ReleaseHandle;
    MyCursor.Free;
  end;
  Mybmp.PixelFormat := pf8bit;
  Mybmp.SaveToStream(StreamName);
  Mybmp.Free;
end;

// Compara as Streams e as Separam quando os Pixels da Bitmap forem iguais.
procedure CompareStream(MyFirstStream, MySecondStream, MyCompareStream
  : TMemoryStream);
var
  I: integer;
  P1, P2, P3: ^AnsiChar;
begin
  MySecondStream.Clear;
  MyCompareStream.Clear;
  GetScreenToBmp(True, MySecondStream);

  P1 := MyFirstStream.Memory;
  P2 := MySecondStream.Memory;
  MyCompareStream.SetSize(MyFirstStream.Size);
  P3 := MyCompareStream.Memory;

  for I := 0 to MyFirstStream.Size - 1 do
  begin
    if P1^ = P2^ then
      P3^ := '0'
    else
      P3^ := P2^;
    Inc(P1);
    Inc(P2);
    Inc(P3);
  end;

  MyFirstStream.Clear;
  MyFirstStream.CopyFrom(MySecondStream, 0);
end;

// Modifica as Streams para reajustar os Pixels da Bitmap
procedure ResumeStream(MyFirstStream, MySecondStream, MyCompareStream
  : TMemoryStream);
var
  I: integer;
  P1, P2, P3: ^AnsiChar;
begin
  P1 := MyFirstStream.Memory;
  MySecondStream.SetSize(MyFirstStream.Size);
  P2 := MySecondStream.Memory;
  P3 := MyCompareStream.Memory;

  for I := 0 to MyFirstStream.Size - 1 do
  begin
    if P3^ = '0' then
      P2^ := P1^
    else
      P2^ := P3^;
    Inc(P1);
    Inc(P2);
    Inc(P3);
  end;

  MyFirstStream.Clear;
  MyFirstStream.CopyFrom(MySecondStream, 0);
  MySecondStream.Position := 0;
end;

end.
