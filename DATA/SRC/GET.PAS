unit get;
{$O+}
interface
procedure getstatus(cart:string; var description:string; var Typestat:string;
                    var rom:integer; var cmnt:string);
implementation
uses beb,dos;
{$V-}

procedure getstatus(cart:string; var description:string; var Typestat:string;
                    var rom:integer; var cmnt:string);

procedure HexByte(var S:string; V:byte);
Const
    HexChars : Array[0..15] of Char = '0123456789ABCDEF';
begin
  S[0] := #2;
  S[1] := HexChars[V shr  4];
  S[2] := HexChars[V and 15];
end;

procedure HexWord(var S:string; V:word);
begin
  S := Word2Hex(V);
end;

procedure Error(Files,txt:string);
begin
  writeln('Error | ',files:20,'| ',txt:48);
end;

function fgetC(var F:File):string;
var ch:string;
begin
  blockread(F,ch,1);
  fgetC := ch;
end;

var
  checkcrc:integer;
   Types:string[4];
   Typesarr:array[0..6] of string[4];
   Buf:array[0..16383] of byte;
   Buf2:array[0..16383] of word;
   B0,B1,B2,B3,B4:string[15];
   F:FILE;
   I,K:integer;
   Name:string[50];
   Comment:string;
   Checksum,Producer,RealCRC:Word;
   Version,Complement,RealComp:Byte;
   RAMBanks,ROMBanks:integer;

function wordcvt(int:byte):word;
begin
  wordcvt := int; {hehehe}
end;

label outtahere;

begin
  Typesarr[0]:='R...';
  Typesarr[1]:='R..1';
  Typesarr[2]:='RW.1';
  Typesarr[3]:='RWB1';
  Typesarr[4]:='????';
  Typesarr[5]:='R..2';
  Typesarr[6]:='R.B2';

  checkcrc := 0;

   if copy(cart,1,1) <> '-' then begin
    assign(f,cart);
    reset(F,sizeof(byte));
    if doserror <> 0 then Error(cart,'Couldn''t open file.')
    else begin
      blockread(F,Buf,16384);
      if(sizeof(Buf)<>16384) then
        Error(cart,'Couldn''t read header.')
      else begin
        Comment:='';
{307 was 308}
        For I := 307 to 324 do
          If Buf[I]>32{' '} then Name[I-307] := chr(Buf[I])
            else Name[I-307] := ' ';
        Name[I-307]:=#0;

        if((Buf[327]<=7) and (Buf[327]<>4)) then begin
          Types:=Typesarr[Buf[327] mod 7];
          ROMBanks:=2 shl Buf[328];
          if ((Buf[327]<>2)and(Buf[327]<>3)) then
            RAMBanks:= -1 else RAMBanks := (1 shl Buf[329]*2) shr 1;
        end
        else begin
          Types:='????';ROMBanks:=1;RAMBanks:=-1;
          Comment := Comment + '[Invalid Types]';
        end;
        if(RAMBanks<0) then B0 := B0 + '    ';
{$R-}
        Checksum:=(wordcvt(Buf[334] shl 8))+Buf[335];
        HexWord(B2,Checksum);
        Complement:=Buf[333];
        HexByte(B3,Complement);
        Producer:=(wordcvt(Buf[331] shl 8))+Buf[330];
        Version:=Buf[332];
{$R+}
        {** Checking the cartridge complement, CRC, size: **}
        if (CheckCRC=1) then begin
          RealComp := 25;
          for I := 308 to 333 do RealComp := RealComp + Buf[I];
          RealComp:=256-RealComp;
          if(RealComp<>Complement) then begin
            HexByte(B1,RealComp);
          end;

          RealCRC:=RealCRC - Buf[334]-Buf[335];
          for K := 0 to 16384 do RealCRC := RealCRC + Buf[K];
          For I := ROMBanks - 1 downto 0 do begin
            blockread(F,Buf,16384);
            if sizeof(Buf) <> 16384 then goto outtahere
            else
              for K := 0 to 16384 do RealCRC := RealCRC + Buf[K];
          end;
          outtahere:
          if (I=1) then Comment:=Comment+'[File Too Short]'
          else
            if (fgetc(F)<>#26{EOF}) then Comment := comment + 'File is too long. '
            else
              if (Checksum <> RealCRC) then begin
                HexWord(B1,RealCRC);
              end;
        end;

        { Printing out the information line }
        HexWord(B1,Producer);
        if(length(Comment)>1) then
          writeln('Error -',cart:20,'| ',Comment, ' |')
        else begin
          description := name;
          Typestat := Types;
          ROM := ROMBanks*16;
          cmnt := Comment;
        end;
      end;
      close(F);
    end;
   end;
end;

end.