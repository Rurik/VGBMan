uses cheat,beb;
var f,f2:text;
    s:string;
begin
  randseed := 31337;
  assign(f,paramstr(1));
  reset(f);
  assign(f2,'A.');
  rewrite(f2);
  while not eof(f) do begin
    readln(f,s);
    writeln(f2,encrypt(s));
  end;
  close(F);
  close(f2);
end.