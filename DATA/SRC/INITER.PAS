unit initer;

interface
  uses overlay, ovrumb;
implementation
const myBufSize = 300000;

begin
  writeln('Initing EMS Overlay system ...');
  OvrInit('VGBMAN.OVR');
{  OvrSetBuf(MyBufSize);
  OvrMovBufToUMB;}
  if OvrResult <> ovrOk then begin
    writeln(ovrresult);
    case OvrResult of
      ovrError: Writeln('Program has no overlays.');
      ovrNotFound: Writeln('Overlay file not found.');
    end;
    Halt(1);
  end;
end.