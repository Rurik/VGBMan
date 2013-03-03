unit link;
{$A+,B-,D+,E+,F+,G+,I+,L+,N-,O+,P-,Q+,R+,S+,T-,V-,X+}
interface
Const
  desclen = 19;
Type
  recType=^recType2;
  listType= String[12];
  SizeType= String[15];
  DescType= string[desclen];
  MemType= string[4];
  recType2 = record
    List:ListType;
    Size:SizeType;
    Desc:DescType;
    Mem:Memtype;
    next:rectype;
  end;
  cfgtype=^cfgtype2;
  cfgType2=record
    sound:boolean;
    verbose:byte;
    video:byte;
    background:string;
    stereo:byte;
    volume:integer;
    ifreq:integer;
    mainprog:string;
    unzip:string;
    zip:string;
  end;

procedure forward(var rec:rectype);
procedure Backword(head:rectype;var rec:rectype);
procedure settofirst(first:rectype; var rec:rectype);
procedure seeklink(first:rectype; var rec:rectype; pos:integer);
procedure addlink(var rec:Rectype);
procedure createfirst(var rec:rectype);
procedure rmlink(head:rectype;var rec:rectype);
implementation

uses crt;
Var
  numfiles:Integer;

procedure forward(var rec:rectype);
begin
  rec := rec^.next;
end;

procedure Backword(head:rectype;var rec:rectype);
var Temp: RecType;
begin
  Temp := Head;
  if Temp <> rec then
    while Temp^.Next <> Rec do Temp := Temp^.Next;
  Rec := Temp;
end;

procedure settofirst(first:rectype; var rec:rectype);
begin
  rec := first;
end;

procedure seeklink(first:rectype; var rec:rectype; pos:integer);
var temp:rectype;
    i:integer;
begin
  i := 1;
  new(temp);
  temp := rec;
  settofirst(first,rec);
  if pos = 1 then exit;
  while ((i < pos) and (rec^.next <> NIL)) do begin
    forward(rec);
    inc(i);
  end;
  if (i < pos) then begin
    writeln('An error has occured in data.  Attempt to seek past extremes');
    writeln('Please send a letter to the author concerning "Seek ',pos,' end at ',i,'"');
    rec := temp;
    dispose(temp);
    exit;
  end;
  dispose(temp);
end;

procedure addlink(var rec:Rectype);
begin
  new(rec^.next);
  rec := rec^.next;
  rec^.next := NIL;
end;

procedure createfirst(var rec:rectype);
begin
  new(Rec);
  rec^.next := NIL;
end;

procedure list(head,rec:Rectype);
begin
  settofirst(head,rec);
  while rec <> NIL do begin
    writeln(rec^.list);
    rec := rec^.next;
  end;
end;

procedure rmlink(head:rectype;var rec:rectype);
begin
  backword(head,rec);
  rec^.next := rec^.next^.next
end;

{var head,tail:rectype;
begin
  createfirst(head);
  tail := head;
  tail^.list := 'Hello #1';
  addlink(tail);
  tail^.list := 'hello #2';
  addlink(tail);
  tail^.list := 'hello #3';
  numfiles := 3;
  list(head,tail);
  settofirst(head,tail);
  forward(tail);
  rmlink(head,tail);
  list(head,tail);
  dispose(tail);}
begin
end.