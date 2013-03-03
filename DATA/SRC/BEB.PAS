unit BeB;
{ $O+}
{$V-}
{$F+}
{$M $4000,0,655360}

interface
  uses dos, crt, redir, qb;
  type str127=string[127]; string255=string[255];

  FUNCTION EXECUTE(Name : PathStr ; Tail : STR127) : WORD;
  function Dosshell(command:string):integer;
  function trimchar(s:string; c:char):string;
  function date:string;
  function drive_exists(c:char):boolean;
  function get_default_Drive:byte;
  PROCEDURE MaskedReadLn(VAR s : String; mask : String; fillCh : Char);
  function numdrives:integer;
  procedure flushkeybuffer;
  Function DirExist(st_Dir:DirStr) : Boolean;
  function trim(s:string):string;
  function trimspace(t:string):string;
  function Encrypt(s:string):String;
  function wordsinstring(s:string):integer;
  function getword(s:string; num:integer):string;
  function hex2dec(hex:string):longint;
  Function LastDrive: Char; 
  function exponent(base,power:integer):longint;
  Function Byte2Hex(numb : Byte): String;
  Function Numb2Hex(numb: Word): String;
  FUNCTION Hex2Long(S : STRING) : LONGINT;
  Function Word2Hex(num: Word): String;
  procedure shell(prog,cmdline:string);
  function filesizeof(s:string):longint;
  function justifyleft(s:string;i:integer):string;
  function writecorrect(s:string):string;
  function readlim(x,y,fg,bg,len:word):string255;
  function file_exists(s:string): boolean;
  function locase(c:char):char;
  function LeadingZero(w : Word) : String;
implementation

function trimchar(s:string; c:char):string;
var t:string; i:integer;
begin
  t := ''; i := 0;
  for i := 1 to length(s) do if s[i] <> c then t := t + s[i];
  trimchar := t;
end;

function drive_exists(c:char):boolean;
var a:searchrec;
begin
  findfirst(c+':\*.*',anyfile,a);
  drive_exists := doserror = 0;
end;

function numdrives:integer;
var c:char;
    i:integer;
begin
  i := 0;
  for c := 'C' to lastdrive do
    if drive_exists(c) then inc(i);
  numdrives := i;
end;

procedure shell(prog,cmdline:string);
var ok:boolean;
begin
  ok := false;
  ok := setoutput('NUL');
  swapvectors;
  exec(fsearch(prog,getenv('PATH')),cmdline);
  swapvectors;
  if ok then canceloutput;
end;

function trim(s:string):string;
begin
  trim := ltrim(rtrim(s));
end;

function getaword(s:string;wordnum:integer):string;
var i,j:byte;
    p:string;
begin
   p:=s;i:=1;j:=1; getaword := '';
   if wordnum = 1 then begin
      while not(p[i] in [' '{,'.','"','''',',','!','?'}]) do inc(i);
      delete(p,i,(length(p)-i)+1);
   end {if}
   else begin
      repeat
         i := pos(' ',p);
         if i = 0 then begin
           getaword := '';
           exit;
         end;
         delete(p,1,i);
         inc(j);
      until j = wordnum;
      i := 1;
      while not(p[i] in [' '{,'.','"','''',',','!','?'}]) do inc(i);
      delete(p,i,(length(p)-i)+2);
  end; {else}
   getaword := p;
end; {getword}

function LeadingZero(w : Word) : String;
var
  s : String;
begin
  Str(w:0,s);
  if Length(s) = 1 then
    s := '0' + s;
  LeadingZero := s;
end;

function date:string;
var
  y, m, d, dow : Word;
begin
  GetDate(y,m,d,dow);
  date := leadingzero(m)+'/'+leadingzero(d)+'/'+copy(leadingzero(y),3,2);

end;

function filesizeof(s:string):longint;
var f:file of byte;
begin
  assign(f,s);
  reset(f);
  filesizeof := filesize(f);
  close(f);
end;

function justifyleft(s:String;i:integer):string;
begin
  justifyleft := s + space(i - length(s));
end;

function locase(c:char):char;
begin
  if c in ['A'..'Z'] then c := chr(ord(c)+32);
  locase := c;
end;

function writecorrect(s:string):string;
var temp:integer;
begin
  s[1] := upcase(s[1]);
  temp := 1;
  for temp := 2 to length(s) do begin
    if s[temp-1] = #32 then s[temp] := upcase(s[temp]) else s[temp] := locase(s[temp]);
  end;
  writecorrect := s;
end;

  function readlim(x,y,fg,bg,len:word):string255;
  var
    out:string[1];
    charout:char;
    tempstring:string255;
  begin
    readlim:=''; tempstring:=''; textcolor(fg); textbackground(bg);
    gotoxy(x,y);
    out[1]:=#0;
    repeat
      charout:=readkey;
      out:=charout;
      case out[1] of
        #8:if length(tempstring)>=1 then
             begin
               delete(tempstring,length(tempstring),1);
               write(#8+#32+#8);
             end else
               begin
                 sound(1000);
                 delay(5);
                 nosound;
               end;
        else if length(tempstring)<=len then
          begin
            tempstring:=tempstring+out[1];
            write(out[1]);
          end else
            begin
              sound(1000);
              delay(5);
              nosound;
            end;
      end;
    until out[1]=#13;
    writeln;
    readlim:=tempstring;
  end;

function file_exists(s:string):boolean;
var a:file;
begin
  assign(a, s);
  {$I-}
  reset(a);
  {$I+}
  if ioresult <> 0 then
    file_exists := false
  else begin
    close(a);
    file_exists := true;
  end;
  if s = '' then file_exists := false;
end;

function exponent(base,power:integer):longint;
var n:integer;
    total:longint;
begin
  total := 1;
  for n := 1 to power do total := total * base;
  exponent := total;
end;

function hex2dec(hex:string):longint;
var i,temp:integer;
    result:longint;
begin
  if length(hex) <> 4 then exit;
  i := 0; temp := 0; result := 0;
  for i := 1 to 4 do begin
    if hex[i] in ['A'..'F'] then temp := ord(hex[i]) - 55
    else temp := value(hex[i]);
    result := result + (temp * (exponent(16,4-i)));
  end;
  hex2dec := result;
end;


Function Byte2Hex(numb : Byte): String;       { Converts Byte to hex String }
  Const
    HexChars : Array[0..15] of Char = '0123456789ABCDEF';
  begin
    Byte2Hex[0] := #2;
    Byte2Hex[1] := HexChars[numb shr  4];
    Byte2Hex[2] := HexChars[numb and 15];
  end; { Byte2Hex }

Function Numb2Hex(numb: Word): String;        { Converts Word to hex String.}
  begin
    Numb2Hex := Byte2Hex(hi(numb))+Byte2Hex(lo(numb));
  end; { Numb2Hex }

FUNCTION Hex2Long(S : STRING) : LONGINT;

    FUNCTION ANumBin (B : STRING) : LONGINT; Assembler;
    ASM
      LES DI, B
      XOR CH, CH
      MOV CL, ES : [DI]
      ADD DI, CX
      MOV AX, 0
      MOV DX, 0
      MOV BX, 1
      MOV SI, 0
      @LOOP :
        CMP BYTE PTR ES : [DI], '1'
        JNE @NotOne
          ADD AX, BX   {add power to accum}
          ADC DX, SI
        @NotOne :
        SHL SI, 1      {double power}
        SHL BX, 1
        ADC SI, 0
        DEC DI
      LOOP @LOOP
    END;

CONST
  HexDigits : ARRAY [0..15] OF CHAR = '0123456789ABCDEF';
  Legal     : SET OF Char = ['$','0'..'9','A'..'F'];
  BinNibbles : ARRAY [0..15] OF ARRAY [0..3] OF CHAR = (
    '0000', '0001', '0010', '0011',
    '0100', '0101', '0110', '0111',
    '1000', '1001', '1010', '1011',
    '1100', '1101', '1110', '1111');

VAR I : BYTE;
    O : STRING;

BEGIN
  O := '';
  Hex2Long := 0;       { Returns zero if illegal characters found }
  IF S = '' THEN EXIT;
  FOR I := 1 TO LENGTH(S) DO
    BEGIN
      IF NOT (S[i] in LEGAL) THEN EXIT;
      O := O + binNibbles[PRED(POS(S[i],Hexdigits))];
    END;
  Hex2Long := ANumBin(O)
END;

(* Hex converts a number (num) to Hexadecimal.                      *)
(*    num  is the number to convert                                 *)
(*    nib  is the number of Hexadecimal digits to return            *)
(* Example: Hex(31, 4) returns '001F'                               *)

Function Word2Hex(num: Word): String;
 Assembler;
ASM
      PUSHF
      LES  DI, @Result
      XOR  CH, CH
      MOV  CL, 4 {4 digits big}
      MOV  ES:[DI], CL
      JCXZ @@3
      ADD  DI, CX
      MOV  BX, num
      STD
@@1:  MOV  AL, BL
      AND  AL, $0F
      OR   AL, $30
      CMP  AL, $3A
      JB   @@2
      ADD  AL, $07
@@2:  STOSB
      SHR  BX, 1
      SHR  BX, 1
      SHR  BX, 1
      SHR  BX, 1
      LOOP @@1
@@3:  POPF
End;

{ I have an Integer to hex in pascal with ASM: }
Function HexOf(I : Longint) : String; Assembler;
  Asm
    jmp   @1                         { Skip table }
  @0:
    db    '0123456789ABCDEF'
  @1:
    cld                              { Clear direction flag }
    les   di,@Result                 { ES:DI = Function return data }
    mov   ax,$0008                   { Set String size }
    stosb                            { in the output, }
    mov   cx,4                       { Loop 4x for four bytes }
    mov   si,3
  @2:
    mov   al,byte [I+si]             { Load AL with next byte }
    dec   si
    push  si                         { SAVE index register! }
    mov   bl,al                      { Load DL... }
    mov   dl,bl                      { and BL, }
    and   bx,$00F0                   { prepare and ... }
    {$IFOPT G+}
    shr   bx,4
    {$ELSE}
    shr   bx,1                       { convert BL to high nybble only, }
    shr   bx,1
    shr   bx,1                       { 8088-compatible }
    shr   bx,1
    {$ENDIF}
    and   dx,$000F                   { and DL to low nybble only. }
    mov   si,bx                      { move high nybble into index, }
    mov   al,byte [cs:@0+si]         { read Character for that nybble, }
    stosb                            { Write high nybble }
    mov   si,dx                      { move low nybble into index, }
    mov   al,byte [cs:@0+si]         { read Character for that nybble, }
    stosb                            { Write low nybble }
    pop   si                         { RESTORE index register! }
    loop  @2                         { Dec CX; Loop if CX <> 0 }
  End;


Function LastDrive: Char; Assembler;
Asm
  mov   ah, 19h
  int   21h
  push  ax            { save default drive }
  mov   ah, 0Eh
  mov   dl, 19h
  int   21h
  mov   cl, al
  dec   cx
@@CheckDrive:
  mov   ah, 0Eh       { check if drive valid }
  mov   dl, cl
  int   21h
  mov   ah, 19h
  int   21h
  cmp   cl, al
  je    @@Valid
  dec   cl            { check next lovest drive number }
  jmp   @@CheckDrive
@@Valid:
  pop   ax
  mov   dl, al
  mov   ah, 0Eh
  int   21h           { restore default drive }
  mov   al, cl
  add   al, 'A'
end;

function wordsinstring(s:String):integer;
var spacepos, oldspace, wrd,i:integer;
begin
  s := trimspace(s);
  i:=0;
  spacepos := 0;
  oldspace := 1;
  wrd := 0;
  while i < length(s) do begin
    inc(i);
    if s[i] = ' ' then begin
      spacepos := i;
      inc(wrd);
      if pos(' ',s) > 0 then delete(s,1,1);
      oldspace := spacepos;
    end;
  end;
  wordsinstring := wrd+1;
end;

function getword(s:string; num:integer):string;
Var
  W0rd : String;
  SpacePos, OldSpace, wrd:integer;
  i:byte;
Begin
  i := 0;
  SpacePos := 0;
  OldSpace := 1;
  wrd := 0;
  While i <> Length(S) Do Begin
    inc(i);
    If S[i] = ' ' Then Begin
      SpacePos := i;
      inc(wrd);
      W0rd := Copy(S,OldSpace,SpacePos-OldSpace);
      If Pos(' ',S) > 0 Then Delete(S,1,1);
      OldSpace := SpacePos;
      if wrd = num then getword := W0rd;
    End;
  End;
  if num = wrd + 1 then getword := copy(s,oldspace,i);
end;

Function Encrypt(s: String): String;
  Var x : Byte;
  begin
    Encrypt[0] := s[0];
    For x := 1 to length(s) do
      Encrypt[x] := chr(ord(s[x]) xor (Random(128) or 128));
  end;  { ConvertTxt }

function trimspace(t:String):string;
var s:string;
    i:integer;
begin
  s := t;
  i := 0;
  while i < length(s) - 1 do begin
    inc(i);
    if (s[i] = ' ') and (s[i+1] = ' ') then begin
      delete(s,i,1);
      dec(i);
    end;
  end;
  trimspace := s;
end;

Function DirExist(st_Dir : DirStr) : Boolean;
Var
  wo_Fattr : Word;
  fi_Temp  : File;
begin
  assign(fi_Temp, (st_Dir + '.'));
  getfattr(fi_Temp, wo_Fattr);
  if (Doserror <> 0) then
    DirExist := False
  else
    DirExist := ((wo_Fattr and directory) <> 0)
end; { DirExist. }

procedure FlushKeyBuffer;
begin
  while keypressed do readkey;
end;


PROCEDURE MaskedReadLn(VAR s : String; mask : String; fillCh : Char);
VAR ch : Char; sx, ox, oy : Byte;
BEGIN
  s := ''; ox := WhereX; oy := WhereY; sx := 0;
  REPEAT
    Inc(sx);
    IF (mask[sx] IN ['0', 'A','|']) THEN Write(fillCh)
    ELSE IF (mask[sx] = '_') THEN Write(' ')
    ELSE Write(mask[sx]);
  UNTIL (sx = Length(mask));
  sx := 0;
  WHILE (NOT (mask[sx+1] IN [#32,'0','A','|'])) AND (sx < Length(mask)) DO BEGIN
    Inc(sx);
    s := s + mask[sx];
  END;
  GotoXY(ox + sx, oy);
  REPEAT
    ch := ReadKey;
    IF (ch = #8) THEN BEGIN
      IF (Length(s) > sx) THEN BEGIN
        IF NOT (mask[Length(s)] IN [#32, '0', 'A','|']) THEN BEGIN
          REPEAT
            s[0] := Chr(Length(s) - 1);
            GotoXY(WhereX - 1, WhereY);
          UNTIL (Length(s) <= sx) OR (mask[Length(s)] IN [#32, '0', 'A','|']);
        END;
        s[0] := Chr(Length(s) - 1); GotoXY(WhereX - 1, WhereY);
        Write(fillCh); GotoXY(WhereX - 1, WhereY);
      END
      ELSE BEGIN
        Sound(440);
        Delay(5);
        NoSound;
      END;
    END
    ELSE IF (Length(s) < Length(mask)) THEN BEGIN
      CASE mask[Length(s) + 1] OF
        '0' : IF (ch IN ['0'..'9']) THEN BEGIN
                Write(ch);
                s := s + ch;
              END;
        'A' : IF (UpCase(ch) IN ['A'..'Z']) THEN BEGIN
                Write(upcase(ch));
                s := s + upcase(ch);
              END;
        '|' : IF (Upcase(ch) in ['A'..'F']) or (ch in ['0'..'9']) then begin
                write(upcase(ch));
                s := s + upcase(ch);
              end;
        #32 : BEGIN
                Write(ch);
                s := s + ch;
              END;
      END;
      WHILE (Length(s)<Length(mask))AND(NOT(mask[Length(s)+1] IN [#32,'0','A','|'])) DO BEGIN
        IF (mask[Length(s) + 1] = '_') THEN s := s + ' '
        ELSE s := s + mask[Length(s) + 1];
        GotoXY(WhereX + 1, WhereY);
      END;
    END;
  UNTIL (ch IN [#13, #27]) and(length(s) >= length(mask));
END;

(*  
MaskedReadLn(Phone, '(000)_000-0000', 'ú');
MaskedReadLn(DOB, '00/00/00', 'ú');
*)

{ Gets the current drive number.
  Part of the Heartware Toolkit v2.00 (HTdisk.PAS) for Turbo Pascal.
  Author: Jose Almeida. P.O.Box 4185. 1504 Lisboa Codex. Portugal.
          I can also be reached at RIME network, site ->TIB or #5314.
  Feel completely free to use this source code in any way you want, and, if
  you do, please don't forget to mention my name, and, give me and Swag the
  proper credits. }

FUNCTION Get_Default_Drive : byte;
{ DESCRIPTION:
    Gets the current drive number.
  SAMPLE CALL:
    NB := Get_Default_Drive;
  RETURNS:
    A = 0, B = 1, C = 2, etc. }

var
  HTregs : registers;

BEGIN { Get_Default_Drive }
  HTregs.AH := $19;
  MsDos(HTregs);
  Get_Default_Drive := HTregs.AL
END; { Get_Default_Drive }

Function DosShell(command:String):Integer;
Var
 OldHeapEnd,
 NewHeapEnd: Word;
 Error:Integer;
Begin
 Error:=0;
 If MemAvail<$1000 then Error:=8;
 If Error=0 then Begin
  NewHeapEnd:=Seg(HeapPtr^)-PrefixSeg;
  OldHeapEnd:=Seg(HeapEnd^)-PrefixSeg;
   asm
    mov ah,4Ah
    mov bx,NewHeapEnd
    mov es,PrefixSeg
    Int 21h
    jnc @EXIT
    mov Error,ax
    @EXIT:
   end; {asm}
  If Error=0 then begin
   SwapVectors;
   Exec(GetEnv('COMSPEC'),command);
   SwapVectors;
    asm
     mov ah,4Ah
     mov bx,OldHeapEnd
     mov es,PrefixSeg
     Int 21h
     jnc @EXIT
     mov Error,ax
     @EXIT:
    end; {asm}
  end;   {If}
 end;    {If}
 DosShell:=Error;
end;     {Function}

(*EXECUTE shrinks your programs memory allocation to the smallest possible value,
then runs the program and then expands it back up again. Works in TP 6.0 and
7.0!
*)

PROCEDURE ReallocateMemory(P : POINTER); ASSEMBLER;
ASM
  MOV  AX, PrefixSeg
  MOV  ES, AX
  MOV  BX, WORD PTR P+2
  CMP  WORD PTR P,0
  JE   @OK
  INC  BX

 @OK:
  SUB  BX, AX
  MOV  AH, 4Ah
  INT  21h
  JC   @X
  LES  DI, P
  MOV  WORD PTR HeapEnd,DI
  MOV  WORD PTR HeapEnd+2,ES

 @X:
END;

FUNCTION EXECUTE(Name : PathStr ; Tail : STR127) : WORD; ASSEMBLER;
ASM
  {$IFDEF CPU386}
  DB      66h
  PUSH    WORD PTR HeapEnd
  DB      66h
  PUSH    WORD PTR Name
  DB      66h
  PUSH    WORD PTR Tail
  DB      66h
  PUSH    WORD PTR HeapPtr
  {$ELSE}
  PUSH    WORD PTR HeapEnd+2
  PUSH    WORD PTR HeapEnd
  PUSH    WORD PTR Name+2
  PUSH    WORD PTR Name
  PUSH    WORD PTR Tail+2
  PUSH    WORD PTR Tail
  PUSH    WORD PTR HeapPtr+2
  PUSH    WORD PTR HeapPtr
  {$ENDIF}
  CALL ReallocateMemory
  CALL SwapVectors
  CALL DOS.EXEC
  CALL SwapVectors
  CALL ReallocateMemory
  MOV  AX, DosError
  OR   AX, AX
  JNZ  @OUT
  MOV  AH, 4Dh
  INT  21h

 @OUT:
END;

begin
end.