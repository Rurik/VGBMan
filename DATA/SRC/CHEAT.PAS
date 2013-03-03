unit cheat;
{ $O+}
interface
uses beb,qb,crt,pipes;
type commandlinetype2=array[1..100] of string;
     commandlinetype=^commandlinetype2;
var
{***********************************************}
  commandline:commandlinetype;
  commandlines:integer;
{***********************************************}
  procedure writecheat(desc,path:string);
procedure writegenie(desc,path:string; var commandline:commandlinetype);
  {function writegenie(desc,path:string):string;}
implementation

var numcodes:integer;

procedure initread(filename:string; desc:string);
var s:string;
    temp:string;
    i:integer;
    found,descr:boolean;
    f:text;
label getout;
begin
  assign(f,filename);
  reset(F);
  numcodes := 0;
  while not eof(f) do begin
    s := '';
    readln(f,s);
    s := encrypt(s);
    temp := '';
    found:=false;
    if copy(s,1,2) = '><' then begin
      inc(numcodes);
      for i := 2 to WordsInString(s) do temp := temp + getword(s,i) + ' ';
      temp := rtrim(temp);
      if ucasE(temp) = ucase(desc) then begin
        found := true;
        descr := false;
        readln(f,s);
        s := encrypt(s);
        if copy(s,1,2) = '><' then goto getout;
        repeat
          descr := true;
          writeln(s);
          readln(f,s);
          s := encrypt(s);
        until ((eof(F)) or (copy(s,1,2) = '><'));
        close(f);
        exit;
      end;
    end;
  end;
  getout:
  close(F);
  if not(found) then writeln('This file was not found in database');
  if not(descr) then writeln('No cheats available for this file');
end;


procedure initgg(filename:string; desc:string;var cmdline:string);
type a=record
  bit:boolean;
  name:string;
  desc:string;
end;

var s:string;
    temp:string;
    i:integer;
    num:integer;
    found:boolean;
    descr:boolean;
    f:text;
    C:Char;
    posi:integer;
    first:integer;
    data:array [1..100] of a;
    numlines:integer;
    textdata:array[1..20] of string;


procedure writeitems(numfiles:integer;var cnt:integer);
const pagesize = 10;
var cont:integer;

function number:integer;
begin
  number := cont - pagesize + posi - 1;
end;

begin
  clrscr;
  textcolor(15);
  for cont := 1 to numlines do writeln(textdata[cont]);
  pipeln('|09 ³ |15 Genie Code   |09³  |15 Description ');
  For Cont := First To First + pagesize do begin
    If (Cont - First + 1 {has to be} = posi) Then begin
      TextBackground(Blue);
      TextColor(Yellow);
    end
    Else begin
      TextBackGround(Black);
      TextColor(LightGray);
    end;
    GotoXY(2, Cont - First + numlines + 2); {3 so that we start at y of 3}
    if cont <= num then begin
      if data[cont].bit then begin
        textcolor(9); write('['); textcolor(15); write('X');
        textcolor(9); write(']'); textcolor(7);
        writeln(data[Cont].name,'  ',data[cont].desc);
      end
      else begin
        textcolor(9); write('[ ]'); textcolor(7);
        writeln(data[Cont].name,'  ',data[cont].desc);
      end;
    end
    else writeln('                          ');
  end;
  cnt := cont;
end;


procedure execute(cont:integer);
const pagesize = 10;
var c2:char;
    code:string;
function number:integer;
begin
  number := cont - pagesize + posi - 1;
end;

begin
    if C = #0 then c2 := readkey else c2 := #1;
    If (C2 = #72) Then begin {up}
      If (posi > 1) Then Dec(posi)
      Else
        If (First > 1) Then begin
          Dec(First);
        end;
    end;
    If (C2 = #80) Then begin {down}
      if number < num then begin
        if (posi + 1 <= num) then begin
          If (posi < pagesize+1) Then
            Inc(posi)
          else
          If (First + pagesize < num) Then begin
            Inc(First);
          end
        end;
      end;
    end
    {pgdn}
    else if c2 = #81 then begin
      if number <> num then begin
        if (number + pagesize <= num) then begin
          inc(first,pagesize);
        end
        else posi := (num-first)+1;
      end;
    end
    {end pgdn}
    {pgup}
    else if c2 = #73 then begin
      if (first - pagesize >= 1) then begin
        dec(first,pagesize);
      end
      else begin
        posi := 1;
        first := 1;
      end;
    end
    {end pgup}
    else if c = #32 then
      if data[number].name = 'User       ' then begin
        inc(num);
        clrscr; textcolor(15);
        Writeln('Please enter a code that you would wish to use for this session.');
        Writeln('Note, if this code isn''t in my predefined, please send it to me');
        Writeln('so that I may add it for everyone else.');
        textcolor(7);
        data[num].bit := true;
        MaskedReadln(data[num].name,'|||-|||-|||','ù');
        writeln; flushkeybuffer;
        Write('What does this code do? ');
        readln(data[num].desc);
        data[num].desc := '- '+data[num].desc;
      end
      else data[number].bit := not(data[number].bit);
end;






label getout;
var cont:integer;

procedure clear;
var i:integer;
begin
  for i := 1 to 100 do begin
    data[i].bit := false;
    data[i].name := '';
    data[i].desc := '';
  end;
end;

begin
  clear;
  numlines := 0;
  assign(f,filename);
  reset(F);
  numcodes := 0;
  while not eof(f) do begin
    s := '';
    readln(f,s);
    s := encrypt(s);
    temp := '';
    found:=false;
    if copy(s,1,2) = '><' then begin
      inc(numcodes);
      for i := 2 to WordsInString(s) do temp := temp + getword(s,i) + ' ';
      temp := rtrim(temp);
      if ucasE(temp) = ucase(desc) then begin
        found := true;
        descr := false;
        readln(f,s);
        s := encrypt(s);
        if copy(s,1,2) = '><' then goto getout;
        num := 0;
        repeat
          descr := true;
          if copy(trim(s),4,1) = '-' then begin
            inc(num);
            data[num].name := getword(s,1);
            data[num].bit := false;
            temp := '';
            data[num].desc := copy(s,12,length(s));
          end else begin
            inc(numlines);
            textdata[numlines] := s;
          end;
          readln(f,s);
          s := encrypt(s);
        until ((eof(F)) or (copy(s,1,2) = '><'));
        close(f);
        inc(num);
        data[num].bit := false;
        data[num].name := 'User       ';
        data[num].desc := '- Enter your own';


        first := 1;
        posi := 1;
        repeat
          writeitems(num,cont);
          C := ReadKey;
          execute(cont);
        until c in [#13,#10];
        if found then begin
          temp := ''; i := 0;
          while i <= num do begin
            inc(i);
            if data[i].bit then temp:=temp+' -cheat '+data[i].name;
          end;
          temp := temp + ' ';
        end;
        cmdline := temp;
        exit;


      end;
    end;
  end;
  getout:
  close(F);
  if not(found) or not(descr) then begin
    repeat
      write('How many codes do you wish to use? ');
      readln(s);
    until value(s) in [0..15]; writeln;
    if value(S) = 0 then begin cmdline := ''; exit; end;
    num := value(s);
    s := '';
    for i := 1 to num do begin
      write('Enter a code : ');
      MaskedReadln(temp,'|||-|||-|||','ù');
      s := s + ' -cheat '+temp;
      writeln;
    end;
    cmdline := s;
  end;
end;


var i:integer;

procedure writecheat(desc,path:string);
begin
  randseed := 31337;
  initread(path+'\codes.dat',desc);
  repeat until ord(readkey) in [13,10];
end;

procedure writegenie(desc,path:string; var commandline:commandlinetype);
var s:string;
    i:integer;
begin
  randseed := 31337;
  initgg(path+'\gamegeni.dat',desc,s);
  {Making Commandlines}
  i := 0;
  s := trim(S);
  while i <= wordsinstring(s) do begin
    inc(i);
    inc(commandlines);
    commandline^[commandlines] := getword(s,i)+' '+getword(s,i+1);
    inc(i);
  end;
  dec(commandlines);
end;

end.