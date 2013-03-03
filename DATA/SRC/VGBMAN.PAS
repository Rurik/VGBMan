Program VGBMan;
{$A-,B-,D+,E-,F+,G-,I+,L+,N-,O+,P-,Q-,R+,S+,T+,V-,X+,Y-}

{ $M 65520,0,70000}
{$M 65520,0,655360}

Uses {ovrumb,initer,}vgbtpu,link;
{ $O vgbtpu}{ $O link}{ $O qb}{ $O beb}{ $O cheat}{ $O cdrom}
{ $O link}{ $O color}{ $O mouse}{ $O get}

var head:rectype;
    body:recType;
    cfg:cfgtype;
begin
  createfirst(head);
  body := head;
  initstart(head,body,cfg);
  lightbar(head,body,cfg);
  shutdown(head,body,cfg)
end.
