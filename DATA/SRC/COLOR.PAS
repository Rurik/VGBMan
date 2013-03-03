unit color;
interface
type hex=string[6];
colortype = ^colortype2;
colortype2=record
  schemename:string;
  color0,
  color1,
  color2,
  color3,
  backgroundcolor0,
  backgroundcolor1,
  backgroundcolor2,
  backgroundcolor3,
  spritecolor0,
  spritecolor1,
  spritecolor2,
  spritecolor3,
  windowcolor0,
  windowcolor1,
  windowcolor2,
  windowcolor3:hex;
end;

const usecolor:boolean = false;
procedure choosecolorscheme(var temp:colortype;path:string);
implementation

uses crt,pipes,beb,qb;
var names:array[1..20] of string;
    colors:array[1..50] of string;
    maxcolors:integer;

function getcolor(title,default:string):hex;
var c:char;
    posi:integer;
    choice:string;

function makecolor:hex;
var ok:boolean;
    i:longint;
    temps:string;
label bad1,bad2,bad3,bad4;
begin
  writeln('1) Enter hex value');
  writeln('2) Enter RGB values');
  repeat c := readkey until c in ['1','2'];
  if c = '1' then begin
    bad1:
    ok := true;
    write('Enter hex value - ');
    readln(temps);
    for i := 1 to length(temps) do if not(temps[i] in ['1'..'9','0','A'..'F']) then ok := false;
    if length(temps) <> 6 then ok := false;
    if not ok then begin
      writeln('Invalid hex value');
      goto bad1;
    end;
    makecolor := temps;
  end
  else begin
    bad2:
    write('Enter Red value (0-255) - ');
    readln(i);
    if ((i<0)or(i>255)) then begin
      writeln('Invalid value');
      goto bad2;
    end;
    temps := ''; temps := numb2hex(i);
    bad3:
    write('Enter Green value (0-255) - ');
    readln(i);
    if ((i<0)or(i>255)) then begin
      writeln('Invalid value');
      goto bad3;
    end;
    temps := temps + numb2hex(i);
    bad4:
    write('Enter Blue value (0-255) - ');
    readln(i);
    if ((i<0)or(i>255)) then begin
      writeln('Invalid value');
      goto bad4;
    end;
    temps := temps + numb2hex(i);
    makecolor := temps;
  end;
end;

var x,y:integer;
begin
  posi := 1;
  x:=wherex;y:=wherey;
  repeat
    gotoxy(x,y);
    writeln('Choose a color for ',title);
    writeln('Up/Down/Enter');
    writeln('/=====================\');
    writeln('|',justifyleft(colors[posi],20),'|');
    writeln('\=====================/');
    c := readkey;
    if keypressed then c := readkey;
    If (C = #72) Then begin {up}
      If (posi > 1) Then
        Dec(posi)
    end;
    If (C = #80) Then begin {down}
      if (posi < maxcolors) then inc(posi);
    end;
  until c in [#10,#13];
  if posi=1 then begin
    if ucase(default) = 'WHITE' then getcolor := 'FFFFFF'
    else if ucase(default) = 'BLACK' then getcolor := '000000'
    else getcolor := default;
  end;
  if posi=maxcolors then begin {make a color}
    getcolor := makecolor;
  end;
end;



procedure choosecolorscheme(var temp:colortype;path:string);
var C:Char;
    numfiles,posi,first:integer;
{    data:litebartype;}
    data:colortype;
    ok:boolean;

procedure writeitems(var cnt:integer);
const pagesize = 10;
var cont:integer;

function number:integer;
begin
  number := cont - pagesize + posi - 1;
end;

begin
  clrscr;
  textcolor(15);
  writeln('Pick a scheme, any scheme ...');
  pipeln('|09³ |15 Scheme   |09³');
  For Cont := First To First + pagesize do begin
    If (Cont - First + 1 {has to be} = posi) Then begin
      TextBackground(Blue);
      TextColor(Yellow);
    end
    Else begin
      TextBackGround(Black);
      TextColor(LightGray);
    end;
    GotoXY(4, Cont - First + {numlines}{pagesize +} 3); {3 so that we start at y of 3}
    if cont <= numfiles then begin
      writeln(names[cont]);
    end
    else writeln('                            ');
  end;
  cnt := cont;
end;


procedure execute(cont:integer);
const pagesize = 10;
var c2:char;
    code:string;
    f:file of colortype;
    a:colortype;
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
      if number < numfiles then begin
        if (posi + 1 <= numfiles) then begin
          If (posi < pagesize+1) Then
            Inc(posi)
          else
          If (First + pagesize < numfiles) Then begin
            Inc(First);
          end
        end;
      end;
    end
    {pgdn}
    else if c2 = #81 then begin
      if number <> numfiles then begin
        if (number + pagesize <= numfiles) then begin
          inc(first,pagesize);
        end
        else posi := (numfiles-first)+1;
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
    else if c in [#10,#13] then begin
      if number = numfiles then begin {addscheme}
        clrscr; textcolor(15);
        writeln('You will be asked values for each color.');
        writeln('First, what would you like to call this scheme - ');
        readln(data^.schemename);
        with data^ do begin
          color0 := getcolor('color0','White');
          color1 := getcolor('color1','B0B0B0');
          color2 := getcolor('color2','606060');
          color3 := getcolor('color3','black');
          backgroundcolor0:= getcolor('backgroundcolor0','white');
          backgroundcolor1:= getcolor('backgroundcolor1','B0B0B0');
          backgroundcolor2:= getcolor('backgroundcolor2','606060');
          backgroundcolor3:= getcolor('backgroundcolor3','black');
          spritecolor0:= getcolor('spritecolor0','white');
          spritecolor1:= getcolor('spritecolor1','B0B0B0');
          spritecolor2:= getcolor('spritecolor2','606060');
          spritecolor3:= getcolor('spritecolor3','black');
          windowcolor0:= getcolor('windowcolor0','white');
          windowcolor1:= getcolor('windowcolor1','B0B0B0');
          windowcolor2:= getcolor('windowcolor2','606060');
          windowcolor3:= getcolor('windowcolor3','black');
        end;
        assign(f,'vgbskeme.dat');
        reset(f);
        while not eof(f) do read(f,a);
        write(f,data);
        close(f);
      end
      else begin {use a predefined scheme}
        ok := true;
      end;
    end;
end;






label getout;

procedure initcolor;
begin
{type colortype=record
  name:array[1..20] of string;
  hex:array[1..20] of string[6];
  color:array[1..20] of string;
end;}
  colors[1] := 'Default';
  colors[2] := 'Black';
  colors[3] := 'Red';
  colors[4] := 'White';
  colors[5] := 'Green';
  colors[6] := 'Blue';
  colors[7] := 'Magenta';
  colors[8] := 'Cyan';
  colors[9] := 'Yellow';
  colors[10] := 'Aquamarine';
  colors[11] := 'Brass'            ;
  colors[12] := 'Cadet Blue'       ;
  colors[13] := 'Copper'           ;
  colors[14] := 'Dark Green'       ;
  colors[15] := 'Dark Orchid'      ;
  colors[16] := 'Dark Purple'      ;
  colors[17] := 'Dark Wood'        ;
  colors[18] := 'Dim Grey'         ;
  colors[19] := 'Firebrick'        ;
  colors[20] := 'Flesh'            ;
  colors[21] := 'Forest Green'     ;
  colors[22] := 'Gold'             ;
  colors[23] := 'Goldenrod'        ;
  colors[24] := 'Grey'             ;
  colors[25] := 'Green Copper'     ;
  colors[26] := 'Khaki'            ;
  colors[27] := 'Maroon'           ;
  colors[28] := 'Midnight Blue'    ;
  colors[29] := 'New Tan'          ;
  colors[30] := 'Old Gold'         ;
  colors[31] := 'Orange'           ;
  colors[32] := 'Orchid'           ;
  colors[33] := 'Quartz'           ;
  colors[34] := 'Rich Blue'        ;
  colors[35] := 'Scarlet'          ;
  colors[36] := 'Sea Green'        ;
  colors[37] := 'Semi-Sweet Chocolate';
  colors[38] := 'Sienna'              ;
  colors[39] := 'Slate Blue'          ;
  colors[40] := 'Spring Green'        ;
  colors[41] := 'Steel Blue'          ;
  colors[42] := 'Summer Sky'          ;
  colors[43] := 'Tan'                 ;
  colors[44] := 'Turquoise'           ;
  colors[45] := 'Very Dark Brown'     ;
  colors[46] := 'Violet'              ;
  colors[47] := 'Violet Red'          ;
  colors[48] := 'Yellow Green'        ;
  colors[49] := 'Make your own';
  maxcolors := 49;
end;


procedure init;
var f:file of colortype;
    i:integer;
    b:colortype;
begin
  assign(f,path+'\vgbskeme.dat');
  reset(F);
  for i := 1 to filesize(f) do begin
    read(f,b);
    names[i] := b^.schemename;
  end;
  numfiles := filesize(F);
  close(f);
  inc(numfiles);
  names[numfiles] := 'Enter your own';
end;

var cont:integer;
    f:file of colortype;
begin
  clrscr;
  initcolor;
  first := 1;
  posi := 1;
  ok := false;
  repeat
    init;
    writeitems(cont);
    C := ReadKey;
    execute(cont);
   until ((c in [#13,#10]) and (ok));
   if posi <> numfiles then begin
     assign(f,path+'\vgbskeme.dat');
     reset(f);
     writeln(posi);
     seek(f,posi-1);
     read(f,temp);
     close(f);
   end;
end;


end.