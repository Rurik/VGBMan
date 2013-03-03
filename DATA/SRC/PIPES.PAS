unit pipes;
interface
  procedure Pipe(Strng:string);
  procedure PipeLn(Strng:string);
implementation
uses crt;

Procedure Pipe(Strng : String);
Var Flash,Cnter: Byte;
    c:string;
    ok, done:boolean;
Begin
  For Cnter:=1 to Length(Strng) do Begin
    done := true;    
    If Strng[Cnter] = '|' then Begin
      Inc(Cnter);
      ok := (ord(strng[cnter]) = 49) and (ord(strng[cnter+1]) in [48..53]);
      if ok then begin
        flash := 0;
        inc(Cnter);
        case Strng[Cnter] Of
          '0':textcolor(10);
          '1':textcolor(11);
          '2':textcolor(12);
          '3':textcolor(13);
          '4':textcolor(14);
          '5':textcolor(15);
        end;
      end
      else if not ok then begin
        if Strng[Cnter] = '0' then flash := 0 else flash := 15;
        Inc(Cnter);
        textbackground(flash);
        Case Strng[Cnter] Of
          '0':textcolor(0);
          '1':textcolor(1);
          '2':textcolor(2);
          '3':textcolor(3);
          '4':textcolor(4);
          '5':textcolor(5);
          '6':textcolor(6);
          '7':textcolor(7);
          '8':textcolor(8);
          '9':textcolor(9);
        End;
      end;
    End
      else done := false;
    if not done then Write(Strng[Cnter]);
  End;
end;

Procedure PipeLn(Strng : String);
Var Cnter: Byte;
Begin
  Pipe(Strng+#13#10);
End;

end.