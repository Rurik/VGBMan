{$A+,B-,D+,E+,F+,G+,I+,L+,N-,O+,P-,Q+,R+,S+,T-,V-,X+}
unit Vgbtpu;
{$M 65520,0,655360}
{ $M 65520,0,85360}


interface
Uses Crt,Dos,qb,get,beb,shadow,pipes,cheat,cdrom,link,color,mouse;
procedure shutdown(head,body:rectype;cfg:cfgtype);
procedure initstart(head:rectype;var rec:rectype;var cfg:cfgtype);
procedure lightbar(head,body:rectype;cfg:cfgtype);
implementation

Const
  S = '               ';
  pagesize = 15;
  maxdirs = 100;
  version = '1.C.19'; (*Aug. 19*)
Type
  dirtype = ^dirtype2;
  dirtype2=array[1..maxdirs] of string;
  bool=^boolean;

Var
  quiet:bool;
  debug:bool;
  redirect:bool;
  foundcfg:bool;
  cddrive:bool;
  numfiles:integer;
  NumDirs:Integer;
  Cont:integer;
  posi:integer;
  First:Integer;
  predir:string;
  PathToCfg:string;
  data:Text;
  tempint:integer;
  dir:DirType; (*pointer*)
  {cfg:cfgType;} (*pointer*)
  colordata:colortype;  (*pointer*)


procedure w(s:string; debugb:boolean);
begin
  if not(quiet^) then begin
    if debugb and debug^ then writeln(s);
    if not(debugb) then writeln(s);
    if redirect^ then writeln(data,s)
  end
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
    file_exists := true
  end;
  if s = '' then file_exists := false
end;

procedure del(s:string);
var f:file;
begin
  assign(f,s);
  if file_exists(S) then erase(f)
end;

function buildcmdline(cfg:cfgtype):string;
var s:string;
begin
  s := '';
  if cfg^.sound then s := s + '-sound 1'
  else s:=s+'-sound 0';
  s:=s+' -verbose '+istr(cfg^.verbose);
  s:=s+' -video '+istr(cfg^.video);
  if cfg^.sound then begin
    case cfg^.stereo of
      1:s := s + ' -stereo mono';
      2:s := s + ' -stereo normal';
      3:s := s + ' -stereo reversed'
    end;
    s := s + ' -volume ' + istr(cfg^.volume)
  end;
{  s := s + ' -ifreq ' + istr(cfg^.ifreq);}
  buildcmdline := s
end;

function place:integer;
begin
  place := cont - pagesize + posi -1
end;


function filename(s:String):string;
begin
  filename := copy(s,1,pos('.',s))
end;


function inrec(head,rec:rectype;s:string;Directory:Boolean):boolean;
var there:boolean;
    i:integer;
begin
  there := false;
  if directory then begin
    for i := 1 to numdirs do
      if s = dir^[i] then there := true;
  end
  else begin
    settofirst(head,Rec);
    for i := 1 to numfiles do begin
      forward(rec);
      if s = rec^.list then there := true
    end
  end;
  inrec := there;
  if there then
    w('!! Checking if '+s+' exists in data ... TRUE',true)
  else
    w('!! Checking if '+s+' exists in data ... FALSE',true)
end;


procedure drawframe(cfg:cfgtype);
var i:integer;
    y:integer;
    ch:char;
begin
  textbackground(lightgray);
  gotoxy(1,1);
  for i := 1 to 160 do write(' ');
  textbackground(lightgray);
  for y := 3 to 18 do begin
    ch:=' ';
    for i := 1 to 3 do write(ch);
    gotoxy(28,y); for i := 28 to 80 do write(ch)
  end;
  for y := 1 to 6 do begin
    textcolor(blue);
    ch := ' '; textbackground(lightgray);
    for i := 1 to 80 do write(ch)
  end;
  shadowbox(0,2,27,pagesize+4,yellow,15);
  shadowbox(27,2,46,7,blue,15);
  gotoxy(29,3);textbackground(black);
    pipeln('|15VGB |09Manager |04v1.0');
  gotoxy(29,4);
    pipeln('|04By: |15Brian |09Baskin');
  gotoxy(29,5);
    pipeln('|09Masochist |04on |15IRC');
  gotoxy(29,6);
    pipeln(' beb@waterw.com ');
  shadowbox(46,2,78,7,red,15);
  gotoxy(49,03); textcolor(15); write('1 '); textcolor(8); write('- Change .EXE path');
  gotoxy(49,04); textcolor(15); write('C '); textcolor(8); write('- Look @ cart Cheats');
  gotoxy(49,05); textcolor(15); write('G '); textcolor(8); write('- Run cart w/ Genie Codes');
  gotoxy(49,06); textcolor(15); write('L '); textcolor(8); write('- Create txt file listing');
  shadowbox(30,9,45+desclen,11,blue,15); (*Description box*)
  shadowbox(31,12,62,14,black,blue); (*type box*)
  shadowbox(31,15,62,19,white,cyan); (*mouse box*)
  shadowbox(1,20,76,22,lightred,15); (*cmdline box*)
  gotoxy(30,20); textcolor(9); write('Current Command Line = ');
  gotoxy(3,21);{ textbackground(black);}textcolor(red);
    write(buildcmdline(cfg));textcolor(black);
    for i := length(buildcmdline(cfg)) to 71 do write(' ');
    textbackground(lightgray);
  shadowbox(1,23,76,25,red,15); (*cmdline box*)
  textcolor(black);
  gotoxy(4,24); write('Current .EXE path = ');
  textcolor(red); write(cfg^.mainprog);
  textbackground(white); textcolor(black);
  gotoxy(34,16); write('  UP  ');
  gotoxy(41,16); write(' DOWN ');
  gotoxy(34,18); write(' PGUP ');
  gotoxy(41,18); write(' PGDN ');
  gotoxy(48,16); write(' C ');
  gotoxy(52,16); write(' G ');
  gotoxy(56,16); write(' L ');
  gotoxy(48,18); write(' 1 ');
  gotoxy(52,18); write('  RUN  ');
  gotoxy(60,16); write('E'); gotoxy(60,17); write('S'); gotoxy(60,18); write('C')
end;


procedure resetdir(var dir:dirtype);
var i:integer;
begin
  w('!! Resetting Dirs ...',true);
  for i := 1 to maxdirs do dir^[i] := ''
end;

procedure resetarray(head:rectype; var rec:recType);
var i:integer;
    tempptr:rectype;
begin
  w('!! Resetting variables ...',true);
  settofirst(head,rec);
  tempptr := rec;
  while rec <> NIL do begin
    rec := rec^.next;
    dispose(tempptr);
    tempptr := rec
  end
end;


function CartType(s:string):string;
begin
  if s = 'R...' then CartType := 'ROM';
  if s = 'R..1' then CartType := 'ROM+MBC1';
  if s = 'RW.1' then CartType := 'ROM+MBC1+RAM';
  if s = 'RWB1' then CartType := 'ROM+MBC1+RAM+BATTERY';
  if s = '????' then CartType := 'UNKNOWN';
  if s = 'R..2' then CartType := 'ROM+MBC2';
  if s = 'R.B2' then CartType := 'ROM+MBC2+BATTERY'
end;


{Procedure QuickSort(Var rec:recType;var dir:dirtype;dodir:boolean;woLeft, woRight:Word);
Type
  Item = string[20];

Var
  Pivot,
  Temp : Item;
  index1,
  index2 : Word;
begin
  w('!! Sorting files ...',true);
  index1 := woLeft;
  index2 := woRight;
  if dodir then
    Pivot := dir^[(woLeft + woRight) div 2]
  else
    Pivot := Rec^.list[(woLeft + woRight) div 2];
  Repeat
    if dodir then w('!! Current dir:'+dir^[index1]+' @ position :'+istr(index1),true);
    if not(dodir) then w('!! Current file:'+Rec^.list[index1]+' @ position :'+istr(index1),true);
    (*set index1*)
    if dodir then while(dir^[index1] < pivot) do
      inc(index1);
    if not(dodir) then While (Rec^.list[index1] < Pivot) do
      inc(index1);
    (*end*)
    (*Set index2*)
    if dodir then While (Pivot < dir^[index2]) do
      dec(index2);
    if not(dodir) then While (Pivot < Rec^.list[index2]) do
      dec(index2);
    (*end*)
    if (index1 <= index2) and not(dodir) then begin
      w('!! Swapping #'+istr(index1)+' '+Rec^.list[index1]+' with #'+istr(index2)+' '+Rec^.list[index2],true);
      temp := Rec^.list[index1]; Rec^.list[index1] := Rec^.list[index2]; Rec^.list[index2] := temp;
      temp := Rec^.Size[index1]; Rec^.Size[index1] := Rec^.Size[index2]; Rec^.Size[index2] := temp;
      temp := Rec^.Desc[index1]; Rec^.Desc[index1] := Rec^.Desc[index2]; Rec^.Desc[index2] := temp;
      temp := Rec^.Mem[index1]; Rec^.Mem[index1] := Rec^.Mem[index2]; Rec^.Mem[index2] := temp;
      inc(index1);
      dec(index2);
    end
    else
      if (index1 <= index2) and dodir then begin
        temp := dir^[index1]; dir^[index1] := dir^[index2]; dir^[index2] := temp;
        inc(index1);
        dec(index2);
      end
  Until (index1 > index2);
  if (woLeft < index2) then
    QuickSort(Rec, dir, dodir,woLeft, index2);
  if (index1 < woRight) then
    QuickSort(Rec, dir, dodir,index1, woRight)
end;}        (* QuickSort *)


procedure writecfg(cfg:cfgtype);
var f:file of CfgType2;
begin
  w('!! Writing to '+pathtocfg+'vgbman.cfg ...',true);
  assign(f,pathtocfg+'vgbman.cfg');
  rewrite(f);
  write(f,cfg^);
  close(f)
end;

procedure FlushKeyBuffer;
begin while keypressed do readkey end;

procedure makecfg(var cfg:cfgtype);
var c:char;
    s:string;
    x,y:integer;
begin
  pipe('|14** |09Do you want sound? ');
  while not (c in ['Y','N']) do c := upcase(readkey);
  if c = 'Y' then cfg^.sound := true else cfg^.sound := false; writeln(c);
  writeln;
  pipeln('|14** |09Verbose level');
  pipeln('   |140|09 - Silent           |141|09 - Startup messages');
  pipeln('   |142|09 - Illegal writes   |144|09 - Illegal CPU ops');
  pipeln('   |148|09 - Bank switching   -Taken from VGB.DOC');
  pipeln('|14/* 1-8 |09give you sometimes useless data when starting');
  pipeln('|140 |09skips all that |14(|09I use|14) */');
  pipe('|09Choice |14- ');
  flushkeybuffer; c := 'c';
  while not (c in ['0','1','2','4','8']) do c := readkey;
  cfg^.verbose := value(c); writeln(value(c)); writeln;
  pipeln('|14** |09Video Mode');
  pipeln('|14   0 - 320|09x200 |15with |09title screen |141 - 320|09x200 without title screen');
  pipeln('|14   2 - 360|09x144 full screen mode  |143 - 180|09x144 full screen mode');
  pipe('|09Choice |14- ');
  flushkeybuffer; c := 'c';
  while not (c in ['0','1','2','3']) do c := readkey;
  cfg^.video := value(c); writeln(value(c)); writeln;
  pipeln('|14** |09Stereo |15Type');
  pipeln('   |141) |09mono');
  pipeln('   |142) |09normal');
  pipeln('   |143) |09reversed');
  pipe('|09Choice |14- ');
  flushkeybuffer;
  while not (c in ['1','2','3']) do c := readkey;
  cfg^.stereo := value(c); writeln(value(c));
  pipe('|14** |09Stereo volume |14(0..15 - |09Only on SBPro|14/16) - ');
  x := wherex; y := wherey; s := '99';
  repeat
    gotoxy(x,y);
    write('    '+#8+#8+#8+#8);
    readln(s)
  until ((value(s) >= 0) and (value(s) <= 15));
  cfg^.volume := value(s);
  writeln;
{  pipeln('|14** |09IFrequency |14(|09High Num|14=|10Fast|14; |09Low Num|14=|10Slow|14; 0=|09Disable|14) - ');
  pipe('   |09Values |15of |140 |15to |1432767 - ');
  x := wherex; y := wherey;
  repeat
    gotoxy(x,y);
    write('    '+#8+#8+#8+#8);
    readln(s)
  until ((value(s) >= 0) and (value(s) <= maxint));
  cfg^.ifreq := value(s);}
  Pipeln('|09Scanning for |15vgb-dos.exe |09...');
  s := '';
  writeln(getenv('PATH'));
  s := '' {fsearch('vgb-dos.exe',getenv('PATH'))};
  writeln('hello');
{  if s = '' then begin
    pipeln('|15vgb-dos.exe |09not found ... ');
    repeat
      write('Enter path+filename to the emulator - ');
      readln(s)
    until file_exists(s)
  end;
  cfg^.mainprog := s;
  Pipeln('|09Scanning for |15pkunzip.exe |09...');
  s := fsearch('pkunzip.exe',getenv('PATH'));
  if s = '' then begin
    pipeln('|15pkunzip.exe |09not found ... ');
    repeat
      write('Enter path+filename to the emulator - ');
      readln(s)
    until file_exists(s)
  end;
  cfg^.unzip := s;
  Pipeln('|09Scanning for |15pkzip.exe |09...');
  s := fsearch('pkzip.exe',getenv('PATH'));
  if s = '' then begin
    pipeln('|15pkzip.exe |09not found ... ');
    repeat
      write('Enter path+filename to the emulator - ');
      readln(s)
    until file_exists(s)
  end;
  cfg^.zip := s;}
  cfg^.zip := 'c:\util\pkzip.exe';
  cfg^.unzip := 'c:\util\pkunzip.exe';
  cfg^.mainprog := 'c:\util\vgb-dos.exe';
  writeln(memavail);
  writecfg(cfg);
  FoundCfg^ := True
end;

procedure readcfg(var cfg:cfgtype);
var f:file of CfgType2;
    ok:boolean;
begin
  ok := true;
  if not(FoundCfg^) then ok := false;
  if file_exists(pathToCfg+'vgbman.cfg') and ok then begin
    assign(f,pathToCfg+'VGBMAN.CFG');
    reset(F);
    if filesize(f) <> 0 then read(f,cfg^)
    else ok := false;
    close(f)
  end;
  writeln(cfg^.unzip);
  writeln(cfg^.zip);
  writeln(cfg^.mainprog);readln;
  if not ok then begin
    writeln('Bad or missing VGBMAN.CFG ...');
    writeln('Creating new VGBMAN.CFG ... Hit Enter to continue');
    while not (readkey in [#10,#13]) do;
    makecfg(cfg)
  end
end;

procedure getfiles(head:rectype;var rec:recType; spec:string; dodir:boolean; cfg:cfgtype);

function filesizeof(s:string):longint;
var f:file of byte;
begin
  assign(f,s);
  reset(f);
  filesizeof := filesize(f);
  close(f)
end;


var description:string;
    Typestat:string;
    cmnt:string;
    rom:integer;
    c:Char;
    subdir:boolean;
    size:longint;
    DirInfo:SearchRec;
    filenam:string[9];

label start;
begin
  w('!! Getting files ...',true);
  FindFirst(spec, AnyFile, DirInfo);
  While DosError = 0 do begin
    if DirInfo.Attr=$10 then subdir := true else subdir := false;
    w('!! Found file:'+ dirinfo.name,true);
    if not(inrec(head,rec,dirinfo.name,subdir)) then begin
      if ((Dirinfo.Attr<>$10)and(dodir)) then goto start; (*weed out files*)
      If DirInfo.Name = '.' then goto start; (*weed out curdir*)
      if subdir then begin
        inc(numdirs);
        dir^[NumdirS] := DirInfo.Name + Copy(S,1,12-Length(DirInfo.Name));
        w('!! Adding dir "'+dir^[numdirs]+'" @ position:'+istr(NumDirs),true);
      end
      else
      if not subdir then begin
        inc(numfiles);
        addlink(rec);
   (*pad*)rec^.List := DirInfo.Name + Copy(S,1,12-Length(DirInfo.Name));
        writeln(rec^.list);
        filenam := filename(dirinfo.name);
        w('Found cart: '+dirinfo.name+'  Unzipping ...',false);
        if not cddrive^ then begin
          if debug^ then begin
            {swapvectors;}
            writeln({'/c '+}cfg^.unzip+' '+dirinfo.name+' '+filenam+'GB');
            dosshell('/c '+cfg^.unzip+' '+dirinfo.name+' '+filenam+'GB');
{            execute(cfg^.unzip,dirinfo.name+' '+filenam+'GB');}

{            swapvectors;}
            writeln(memavail,' bytes of memory available at shell');
            readkey;
          end else
            {dosshell('/c '+cfg^.unzip+' '+dirinfo.name+' '+filenam+'GB')]
            {shell(cfg^.unzip,dirinfo.name+' '+filenam+'GB')}
        end;
        if not(file_exists(filenam+'GB')) then begin
          w('This is not a VGBMan Cart ZIP File ... skipping ...',false);
          dec(numfiles); (*It ain't a file, so get rid of it*)
          goto start
        end;
        getstatus(filenam+'GB',description,Typestat,rom,cmnt);
        size := 0;
        size := filesizeof(filenam+'GB');
        if not cddrive^ then del(filenam+'GB');
        if TypeStat <> '????' then begin
          gotoxy(1,wherey); clreol; write('Adding cart ',dirinfo.name);
          w('Valid cart of Type:'+Typestat+'.  Description:'+copy(description,1,desclen),false);
          w('Adding cart '+dirinfo.name+' at position '+istr(numfiles),false);
          rec^.Desc := rtrim(description);
        end
        else begin
          rec^.Desc := 'Invalid'
        end;
        rec^.Mem := Typestat;
        Str(size,rec^.Size);
   (*pad*)rec^.Size := Concat(rec^.Size,Copy(S,1,9-Length(rec^.Size)))
      end
    end;
    start:
    FindNext(DirInfo)
  end
end;

procedure getdrives(var rec:RecType);
var c:char;
begin
  for c := 'C' to LastDrive do if drive_exists(C) then begin
    w('!! Adding '+c+': to data ...',true);
    Inc(numfiles);
    addlink(rec);
    rec^.List := c+':'+Copy(S,1,10);
    rec^.Size := 'ChDrive'+Copy(S,1,2);
    rec^.Desc := c+':'+Copy(S,1,10);
    rec^.Mem := '....'
  end
end;


procedure zipcarts(var rec:RecType; cfg:cfgtype);
var DirInfo:SearchRec;
    filenam:string[9];

begin
  findfirst('*.GB',anyfile,dirinfo);
  while doserror = 0 do begin
    writeln('Gameboy carts have been found, please wait ...');
    w('Found GB File: '+ dirinfo.name+' Zipping it up ...',false);
    filenam :=filename(dirinfo.name);
    if debug^ then begin
      swapvectors;
      exec(cfg^.zip,'-mex '+filenam+'zip '+dirinfo.name+' '+filenam+'sav');
      swapvectors;
      readkey;
    end else
      shell(cfg^.zip,'-mex '+filenam+'zip '+dirinfo.name+' '+filenam+'sav');
    findnext(dirinfo)
  end
end;

procedure weeddirs(var dir:dirtype);
var i:integer;
    i2:integer;
    dir2:DirType;
    ok:boolean;
    dirst:dirstr;
begin
  i2 := 1;
  w('!! Weeding Dirs ...',true);
  new(dir2);
  resetdir(dir2);
  for i := 1 to numdirs do begin
    dirst := trim(dir^[i]);
    ok := false;
    if (direxist(dirst)) or (trim(dir^[i]) = '..') then ok := true;
    if ok then w('!! Dirname:'+dir^[i]+' Dir is kept',true) else w('!! Dirname:'+dir^[i]+' Dir is del''d',true);
    if ok then begin
      dir2^[i2] := dir^[i];
      inc(i2);
    end
    else
      writeln('Deleting ',trim(dir^[i]),'.  It either does not exist, or an error has occured')
  end;
  dir := dir2;
  numdirs := i2-1;
  dispose(dir2)
end;


procedure weedfiles(head:rectype;var rec:rectype);
var i:integer;
    i2:integer;
    ok:boolean;
begin
  w('!! Weeding files ...',true);
  while i < numfiles do begin
    inc(i);
    seeklink(head,rec,i);
    if (file_exists(rec^.list)) then ok := true;
    if copy(rec^.list,2,1) = ':' then ok := false;
    writeln(rec^.list,'|',ok);
    if ok then
      w('!! Filename:'+rec^.list+' file is kept',true)
    else
      w('!! Files:'+rec^.list+' file is del''d',true);
    if not(ok) then begin
      dec(numfiles);
      seeklink(head,rec,i);
      dec(i);
      rmlink(head,rec)
    end
  end;
  for i := 1 to numfiles do begin seeklink(head,rec,i);writeln(rec^.list);end;
  readln;
end;


procedure WriteDescription(head,rec:RecType);
var f:file of rectype2;
procedure writea;
begin
  write(f,rec^)
end;

begin
{  weeddirs(dir);}
  weedfiles(head,rec);
  seeklink(head,rec,numfiles);
  while ((rec^.list = '') and (numfiles>1))do begin
    writeln(rec^.list);
    dec(numfiles);
    seeklink(head,rec,numfiles)
  end;
{  assign(f,'descript.ion');
  rewrite(f);
  for i := 1 to numdirs do begin
    if dir^[i] <> '' then writeln(f,trim(dir^[i]),' <DIR>')
  end;
  for i := 1 to numfiles do writea;
  close(f);}
  assign(f,'vgbman.dsc');
  if file_exists('vgbman.dsc') then reset(f) else rewrite(f);
{ for i := 1 to numfiles do} writea;
  close(f)
end;

procedure readDescription(var rec:RecType);
var f:file of rectype2;
begin
  if not file_exists('vgbman.dsc') then exit;
  assign(f,'vgbman.dsc');
  reset(f);
  read(f,rec^);
  close(f)
end;


procedure init(head:rectype;var rec:rectype;var cfg:cfgtype);
var i:integer;
begin
  commandlines := 0;
  if not(quiet^) then clrscr;
  TextBackground(Black);
  TextColor(LightGray);
  resetdir(dir);
  resetarray(head,rec);
  numfiles := 0;
  cddrive^ := CDR_DRIVE_CHECK(get_default_drive);
  w('Reading in descript.ion ...',false);
  readdescription(rec);
  w('Reading dirs ...',false);
  getfiles(head,rec,'*.*',true,cfg); (*get dirs*)
  if not cddrive^ then begin
    W('Scanning for GB Carts to zip ...',false);
    zipcarts(rec,cfg);
    w('Scanning for ZIPs ...',false);
    getfiles(head,rec,'*.zip',false,cfg);
    gotoxy(1,wherey); clreol;
  end
  else begin
    W('Scanning CD-ROM for GameBoy carts ...',false);
    getfiles(head,rec,'*.gb',false,cfg)
  end;
  writeln('numfiles-',numfiles);
  for i := 1 to numfiles do begin seeklink(head,rec,i);writeln('-',rec^.list);end;readln;

  if numdirs > 0 then begin
    w('Sorting dirs ...',false);
   { quicksort(rec,dir,true,1,numdirs)} (*Sort the dirs now*)
  end;
  if numfiles>0 then begin
    w('Sorting carts ...',false);
   { quicksort(rec,dir,false,1,numfiles)} (*Sort the files now*)
  end;
  w('Reading disk drives ...',false);
  writeln('numfiles-',numfiles);
  for i := 1 to numfiles do begin seeklink(head,rec,i);writeln('-',rec^.list);end;readln;
  getdrives(rec);
  writeln('numfiles-',numfiles);
  for i := 1 to numfiles do begin seeklink(head,rec,i);writeln('-',rec^.list);end;readln;
  if (numfiles>=numdrives) and not(cddrive^) then begin
    w('Writing to DESCRIPT.ION ...',false);
    writeDescription(head,rec)
  end;
  w('Drawing screen ...',false);
  if not(quiet^) then drawframe(cfg)
end;


(*procedure readDescription2(var rec:RecType);
var f:text;
    j,filenum,dirnum:integer;
    s,t:string;
label start;
begin
  filenum := 0;
  t := '';
  DirNum := 0;
  w('!! Reading in DESCRIPT.ION ...',true);
  if file_exists('descript.ion') then begin
    assign(f,'descript.ion');
    reset(f);
    while not(eof(f)) do begin
      start:
      readln(f,s);
      if length(s) < 4 then goto start;
      w('!! Reading '+s,true);
      if getword(s,2) = '<DIR>' then begin
        inc(dirnum);
        dir^[dirnum] := getword(s,1);
      end
      else begin
        inc(filenum);
        rec^.list[FileNum] := getword(s,1);
        rec^.Size[FileNum] := getword(s,2);
        rec^.Mem[FileNum] := getword(s,3);
        rec^.desc[FileNum] :=
          copy(s,pos(rec^.mem[filenum],s)+length(rec^.mem[filenum])+1,length(s)-2);
{       t := '';
        for j := 4 to wordsinstring(s) do t := t + getword(s,j)+' ';
        rec^.Desc[FileNum] := t}
      end
    end;
    close(f)
  end;
  numfiles := filenum;
  numdirs := dirnum
end; *)


function findfile(Path:DOS.PathStr;filename:string): pathstr;
VAR
  SR : SearchRec;
  pathtofile:pathstr;
BEGIN
  pathtofile := '';
  IF Path[Length(Path)] <> '\' THEN (* Make sure last char is '\' *)
    Path := Path + '\';
  if file_exists(path+filename) then pathtofile := path;
  (* Change to directory specified by Path.  Handle root as special case *)
  {$I-}
  IF (Length(Path) = 3) AND (Copy(Path, 2, 2) = ':\') THEN
    ChDir(Path)
  ELSE
    ChDir(Copy(Path, 1, Length(Path) - 1));
  IF IOResult <> 0 THEN
    EXIT; (* Quit if we get a DOS error *)
  {$I-}
  (* Process all subdirectories of that directory, except for *)
  (* the '.' and '..' aliases                                 *)
  FindFirst(Path + '*.*', Directory, SR);
  WHILE DosError = 0 DO BEGIN
    IF ((SR.Attr AND Directory) <> 0) AND
        (SR.Name <> '.') AND (SR.Name <> '..') THEN
      if pathtofile = '' then
        pathtofile := findfile(Path+SR.Name,filename);
    FindNext(SR)
  END; (* while *)
  findfile := pathtofile
END; (*ProcessDirs*)

procedure MakeList(head,rec:rectype);
var f:text;
    total:longint;
    i:integer;
begin
  if numfiles < numdrives then exit;
  total := 0;
  for i := 1 to numfiles do begin
    seeklink(head,rec,i);
    total := total + value(rec^.size)
  end;
  if cddrive^ then assign(f,'C:\FilesList.Txt')
  else
    assign(f,'FileList.Txt');
  rewrite(f);
  writeln(f,'List Created by VGB Manager Version '+version+' By Brian Baskin');
  writeln(f,'');
  (*Name = 13, Desc = 20, Size = 9*)
  writeln(f,'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿');
  writeln(f,'³ Name         ³ Description        ³ Size    ³');
  writeln(f,'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄ´');
  for i := 1 to numfiles do begin
    seeklink(head,rec,i);
    if ((copy(rec^.list,2,1) <> ':')) then
      writeln(f,'³ ',rec^.list+copy(s,1,13-length(rec^.list)),
                '³ ',rec^.desc+copy(s,1,19-length(rec^.desc)),
                '³ ',rec^.size+copy(s,1,08-length(rec^.size)),'³');
    writeln(f,'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄ¿');
    writeln(f,'³ Carts found:',numfiles:3,'.   Disk Space used:',
           trim(comma(total))+copy(s,1,12-length(trim(comma(total)))),' ³');
    writeln(f,'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
    writeln(f,'');
    writeln(f,'Please do not modify any of the seperator characters. (Ä,Å,³,etc)');
    close(f)
  end
end;



procedure makecartcfg(filen, cmdline:string;commandline:commandlinetype);
var f:text;
    i:integer;
begin
  assign(f,filename(filen)+'CFG');
  rewrite(f);
  i := 0;
  while i+2 <= wordsinstring(cmdline) do begin
    inc(i);
    writeln(f,getword(cmdline,i),' ',getword(cmdline,i+1));
    inc(i)
  end;
  for i := 1 to commandlines do writeln(f,commandline^[i]);
  if usecolor then begin
    writeln(f,'-c0 ',colordata^.color0);
    writeln(f,'-c1 ',colordata^.color1);
    writeln(f,'-c2 ',colordata^.color2);
    writeln(f,'-c3 ',colordata^.color3);
    writeln(f,'-bc0 ',colordata^.backgroundcolor0);
    writeln(f,'-bc1 ',colordata^.backgroundcolor1);
    writeln(f,'-bc2 ',colordata^.backgroundcolor2);
    writeln(f,'-bc3 ',colordata^.backgroundcolor3);
    writeln(f,'-sc0 ',colordata^.spritecolor0);
    writeln(f,'-sc1 ',colordata^.spritecolor1);
    writeln(f,'-sc2 ',colordata^.spritecolor2);
    writeln(f,'-sc3 ',colordata^.spritecolor3);
    writeln(f,'-wc0 ',colordata^.windowcolor0);
    writeln(f,'-wc1 ',colordata^.windowcolor1);
    writeln(f,'-wc2 ',colordata^.windowcolor2);
    writeln(f,'-wc3 ',colordata^.windowcolor3)
  end;
  close(f)
end;



function wnumber:integer;
begin
  wnumber := cont - pagesize + posi - 1
end;

function number:integer;
begin
  if wnumber <= numdirs then number := wnumber;
  if wnumber > numdirs then number := wnumber - numdirs
end;

procedure runcart(head,rec:rectype;name, desc,cmdline:string;commandline:commandlinetype;cfg:cfgtype);
var s:string;
    c:char;
    i:integer;
begin
  s := '';
  seeklink(head,rec,number);
  w('Uncompressing '+ rec^.list,false);
  if debug^ then begin
    swapvectors;
    exec(cfg^.unzip,rec^.list+' '+
         filename(rec^.list)+'GB '+filename(rec^.list)+'SAV');
    swapvectors;
    readkey;
  end else
    shell(cfg^.unzip,rec^.list+' '+
          filename(rec^.list)+'GB '+filename(rec^.list)+'SAV');
  if rtrim(ltrim(desc)) = 'SAGA3' then s := ' -vperiod 5000';
  if rtrim(ltrim(desc)) = 'METROID2' then s := ' -nodelay -vperiod 9000';
  makecartcfg(name, cmdline+s,commandline);
  swapvectors;
  exec(cfg^.mainprog,rtrim(filename(name))+'GB');
  swapvectors;
  del(filename(name)+'CFG');
  del(filename(rec^.list)+'GB');
{  w('Removing old .SAV from ZIP ...',false);
  shell(cfg^.zip,'-d '+rec^.list+' '+filename(rec^.list)+'SAV');}
  w('Adding new .SAV to ZIP ...',false);
  shell(cfg^.zip,' -mex '+rec^.list+' '+filename(rec^.list)+'SAV');
  if file_exists(filename(rec^.list)+'SAV') then begin
    writeln(filename(rec^.list),'SAV for some reason, exists.');
    writeln('This should not be, PKZIP didn''t run.');
    writeln('Possibly due to out of memory');
    writeln('The ',filename(rec^.list),'SAV will not be deleted, and you can quit now');
    writeln('by pushing Y else push N');
    write('Quit? ');
    repeat c := upcase(readkey) until c in ['Y','N'];
    if c = 'Y' then halt
  end
end;

procedure lightbar(head,body:rectype;cfg:cfgtype);
const
  C_up      = 0;
  C_down    = 1;
  C_pgup    = 2;
  C_pgdn    = 3;
  C_enter   = 4;
  C_del     = 5;
  C_color   = 6;
  C_list    = 7;
  C_gg      = 8;
  C_cheat   = 9;
  C_ESC     = 10;
  C_home    = 11;
  C_end     = 12;
var
  files:integer;

procedure writeitems(head,rec:rectype);
var Liststring:string;
    attrstring:string;
    memstring:string;
    descstring:string;
begin
  textbackground(lightblue); textcolor(white);
  files := numfiles + numdirs;
  if posi < 1 then posi := 1;
  if first < 1 then first := 1;
  For Cont := First To First + (pagesize) do begin
    If (Cont - First + 1 (*has to be*) = posi) Then begin
      gotoxy(34,13);
      textbackground(blue);
      textcolor(lightblue);
      Write('Type: ');
      textcolor(white);
      memstring := '';
      seeklink(head,rec,cont-numdirs);
      if cont <= numdirs then memstring := '????'
      else
        if copy(rec^.list,2,1) <> ':' then
          memstring := rec^.mem
        else memstring := '????';
        memstring := carttype(memstring);
      memstring := memstring + Copy(S,1,20-Length(memstring));
      writeln(memstring:20);

      gotoxy(32,10);
      textbackground(white); textcolor(black);
      write(' Description:');
        if cont <= numdirs then descstring := dir^[cont]
        else begin
          descstring := ltrim(rec^.Desc)
        end;
        descstring := descstring + Copy(S,1,desclen-Length(descstring));
        textbackground(black); textcolor(white);
        write(' ',copy(descstring,1,desclen-2));
      TextBackground(Blue);
      TextColor(Yellow)
    end
    Else begin
      TextBackGround(Black);
      TextColor(LightGray)
    end;
    GotoXY(2, Cont - First + 3); (*3 so that we start at y of 3*)
    if cont > numdirs then begin
      Liststring := rec^.list;
      attrstring := rec^.Size
    end
    else begin
      ListString := dir^[cont];
      AttrString := '<DIR>'
    end;
    Liststring := Liststring + Copy(S,1,12-Length(Liststring));
    attrstring := attrstring + Copy(S,1,9-Length(attrstring));
    Write(' ', Liststring:12, '  ', attrstring)
  end
end;


procedure input(var b:byte);
var ok:boolean;
    c:char;
    c2:char;
begin
  ok := false; c := #0; b := 255;
  repeat
    if keypressed then begin
      c := upcase(readkey);
      if C = #0 then c2 := readkey else c2 := #1;
      if C2 = #80 then b := C_down;
      if C2 = #72 then b := C_up;
      if C2 = #81 then b := C_pgdn;
      if C2 = #73 then b := C_pgup;
      if C2 = #83 then b := C_del;
      if C2 = #71 then b := C_home;
      if C2 = #79 then b := C_end;
      if C = '1' then b := C_color;
      if C = 'G' then b := C_gg;
      if C = 'C' then b := C_cheat;
      if C = 'L' then b := C_list;
      if C = #27 then b := C_ESC;
      if C in [#13,#10] then b := C_enter
    end
    else
      if mouseleft then begin
        if (mousey = 15) and (mousex in [33..38]) then b := C_up;
        if (mousey = 15) and (mousex in [40..45]) then b := C_down;
        if (mousey = 17) and (mousex in [33..38]) then b := C_pgup;
        if (mousey = 17) and (mousex in [40..45]) then b := C_pgdn;
        if (mousey = 15) and (mousex in [47..49]) then b := C_cheat;
        if (mousey = 15) and (mousex in [51..53]) then b := C_gg;
        if (mousey = 17) and (mousex in [47..49]) then b := C_color;
        if (mousey = 17) and (mousex in [51..56]) then b := C_enter;
        if (mousex = 59) and (mousey in [15..17]) then b := C_ESC;
        if b <> 255 then delay(22)
      end;
    if b <> 255 then ok := true
  until ok
end;

procedure execute(head,rec:rectype;C:byte;var cfg:cfgtype);
var subdir:boolean;
    temp:string;
    ch:char;
begin
    subdir := place <= numdirs;
    If (C = C_up) Then begin (*up*)
      If (posi > 1) Then Dec(posi)
      Else
        If (First > 1) Then begin
          Dec(First)
        end
    end;
    If (C = C_down) Then begin (*down*)
      if number < files then begin
        if (posi < files) then begin
          If (posi < pagesize+1) Then begin
            if number <= numdirs then
              inc(posi)
            else begin
              seeklink(head,rec,number+1);
              if rec^.list <> '' then inc(posi)
            end
          end
          else
          If (First + pagesize < Files) Then begin
            Inc(First)
          end
        end
      end
    end (*down*)
    (*pgdn*)
    else if c = C_pgdn then begin
      if number < files then begin
        if (number+pagesize+1> files) then begin
          first := files - pagesize; posi := pagesize+1
        end else
        if (number+pagesize <= files) then begin
          inc(first,pagesize)
        end
        else posi := (files-first)+1
      end
    end
    (*end pgdn*)
    (*pgup*)
    else if c = C_pgup then begin
      if (first - pagesize >= 1) then begin
        dec(first,pagesize)
      end
      else begin
        posi := 1;
        first := 1
      end
    end
    (*end pgup*)
    (*del*)
    else if c = C_del then begin
      if not(subdir) then begin
       seeklink(head,rec,number);
       if (copy(rec^.list,2,1) <> ':') then begin
         mouseoff;
         temp := ' Are you sure you want to del '+rtrim(rec^.list)+'? ';
         shadowbox(27,11,33+length(temp),13,15,red);
         Gotoxy(29,12); textbackground(red); textcolor(white);
         write(temp);
         ch := upcase(readkey);
         if ch = 'Y' then
           del(rec^.list);
         writeln;
         init(head,rec,cfg);
         drawframe(cfg);
         mouseon
       end
      end
    end
    (*end del*)
    else if C = C_cheat then begin
      mouseoff;
      clrscr;
      writecheat(rtrim(rec^.Desc),predir);
      init(head,rec,cfg);
      drawframe(cfg);
      mouseon
    end
    else if ((C = C_gg) and (not(subdir))) then begin
      mouseoff;
      clrscr;
      seeklink(head,rec,number);
      writegenie(rtrim(rec^.Desc),predir,commandline);
      runcart(head,rec,rec^.list,rec^.desc,buildcmdline(cfg),commandline,cfg);
      init(head,rec,cfg);
      drawframe(cfg);
      mouseon
    end
    else if c = C_color then begin
      mouseoff;
      textbackground(white);
      choosecolorscheme(colordata,predir);
      usecolor := true;
      init(head,rec,cfg);
      drawframe(cfg);
      mouseon
    end
    else if c = C_home then begin
      posi := 1;
      first := 1
    end
    else if c = C_list then begin
      makelist(head,rec)
    end
    else if c = C_enter then begin
      seeklink(head,rec,number);
      if not subdir and (pos(':',rec^.list) > 1) then begin
        w('chdir('+copy(rec^.list,1,2)+'\);',true);
        chdir(copy(rec^.list,1,2)+'\');
        first := 1;
        posi := 1;
        init(head,rec,cfg)
      end
      else if subdir then begin
        chdir(rtrim(dir^[number]));
        first := 1;
        posi := 1;
        init(head,rec,cfg)
      end
      else begin
        mouseoff;
        clrscr;
        seeklink(head,rec,number);
        RunCart(head,rec,rec^.list,rec^.Desc,buildcmdline(cfg),commandline,cfg);
        clrscr;
        init(head,rec,cfg);
        drawframe(cfg);
        mouseon
      end
    end
end;


var c:byte;

begin
  Repeat
    writeitems(Head,body);
    input(c);
    execute(head,body,c,cfg)
  Until (c = C_ESC)
end;


Procedure findvgbmancfg;
var c:char;
    back:integer;
    temps:string;
    D:dirstr;
    n:namestr;
    e:extstr;

label out;
begin
  if not(file_exists(fsearch('vgbman.cfg',getenv('PATH')))) then begin
    for c := 'C' to lastdrive do begin
      writeln('Scanning '+C+':\ for VGBMAN.CFG ...');
      PathToCfg := findfile(c+':\','vgbman.cfg');
      if PathToCfg <> '' then begin
        w('VGBMAN.CFG found in '+pathtocfg,false);
        foundCfg^ := true;
        goto out
      end
    end;
    if PathToCfg = '' then begin
      foundcfg^ := false;
      chdir(predir);
      back := 0;
      temps := fexpand(paramstr(0));
      while pos('\',temps) > 0 do begin
        back := pos('\',temps);
        delete(temps,back,1)
      end;
      inc(back);
      pathtocfg := copy(fexpand(paramstr(0)),1,back);
      if pathtocfg[length(pathtocfg)] <> '\' then
        delete(pathtocfg,length(pathToCfg),1)
    end
  end
  else begin
    FSplit(fexpand(fsearch('vgbman.cfg',getenv('PATH'))), D, N, E);
    foundcfg^ := true;
    PathToCfg := D;
    foundCfg^ := true;
    w('VGBMAN.CFG found in '+pathtocfg,false)
  end;
  out:
end;

procedure checkforzip(backup:string;cfg:cfgtype);
begin
  if ucase(copy(backup,length(backup)-4,4)) = '.ZIP' then shell(cfg^.unzip,backup)
end;

procedure initstart(head:rectype;var rec:rectype;var cfg:cfgtype);
var i:integer;
    backup:string;
label out;
begin
  new(quiet);
  new(debug);
  new(redirect);
  new(foundcfg);
  new(cddrive);
  new(cfg);
  debug^ := false;
  quiet^ := true;
  foundcfg^ := false;
  redirect^ := false;
  cddrive^ := false;
  clrscr;
  getdir(0,predir);
  redirect^ := false;
  if paramcount > 0 then
    for i := 1 to paramcount do
      if ucase(paramstr(i)) = '-D' then debug^ := true
      else if ucase(paramstr(i)) = '-Q' then quiet^ := false;
  if ucase(paramstr(1)) = '-R' then begin
    redirect^ := true; debug^ := true; quiet^ := false
  end;
  if debug^ then begin
    writeln('Debug mode activated ... should be used for testing only ...');
    while not (readkey in [#10,#13]) do
  end;
  if redirect^ then begin
    assign(data,'C:\TESTING.TST');
    rewrite(data)
  end;
  findvgbmancfg;
  randomize;
  (*initing...*)
  (*done*)
  w('Scanning/Reading VGBMAN.CFG ...',false);
  readcfg(cfg);
  if ((paramcount = 1) and
     (ucase(paramstr(1)) <> '-D') and
     (ucase(paramstr(1)) <> '-R')) then begin
    backup := paramstr(1);
    checkforzip(backup,cfg);
    if pos('.',backup) = 0 then backup := backup + '.gb';
    if file_exists(backup) then begin
      textcolor(black); textbackground(black);
      clrscr;
      swapvectors;
      exec(cfg^.mainprog,' '+buildcmdline(cfg)+' '+backup);
      swapvectors;
      halt
    end
  end;
  First := -1;
  posi  := -1;
  chdir('D:');
  chdir('\GAMEBOY\GAMES');
  new(colordata);
  new(commandline);
  new(dir);

  init(head,rec,cfg);
  w('Initiating mouse system ...',true);
  mouseinit;
  mouseon;
  setmousexy(32,15);
  limitmouse(32, 15, 59,17);
  drawframe(cfg)
end;

procedure shutdown(head,body:rectype;cfg:cfgtype);
begin
  chdir(predir);
  writecfg(cfg);
  gotoxy(1,25);
  w('Thank you for running VGBManager... Shutting down.',false);
  resetarray(head,body);
  w('!! Disposing records ...',true);
{  dispose(head); } (*#204 - Invalid Pointer Operation*)
  dispose(colordata);
  dispose(commandline);
  dispose(cfg);
  dispose(dir);
  dispose(quiet);
  dispose(debug);
  dispose(redirect);
  dispose(foundcfg);
  dispose(cddrive);

  w('!! Shutting down mouse system ...',true);
  mouseoff;
  if redirect^ then close(data)
end;


begin
end.