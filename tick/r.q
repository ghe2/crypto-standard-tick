/q tick/r.q [host]:port[:usr:pwd] [host]:port[:usr:pwd]
/2008.09.09 .k ->.q

if[not "w"=first string .z.o;system "sleep 1"];

upd:insert;

/ get the ticker plant and history ports, defaults are 5010,5012
.u.x:.z.x,(count .z.x)_(":5010";":5012");

/ end of day: save, clear, hdb reload
.u.end:{0N!"Starting EOD at: ",string[.z.p];t:tables`.;t@:where `g=attr each t@\:`sym;.Q.hdpf[`$":",.u.x 1;`:.;x;`sym];@[;`sym;`g#] each t;0N!"Finishing EOD at: ",string[.z.p];};

/ init schema and sync up from log file;cd to hdb(so client save can run)
.u.rep:{(.[;();:;].)each x;if[null first y;:()];-11!y;system "cd ",1_-10_string first reverse y};
/ HARDCODE \cd if other than logdir/db

/ connect to ticker plant for (schema;(logcount;log))
.u.rep .(hopen `$":",.u.x 0)"(.u.sub[`;`];`.u `i`L)";

selectFunc:{[tbl;sd;ed;ids;exc]
    .debug.selectFunc:`tbl`sd`ed`ids`exc!(tbl;sd;ed;ids;exc);
    .[selectFuncAPI;(tbl;sd;ed;ids;exc);{-2!"Error selecting data: ",x;()}]
 };

selectFuncAPI:{[tbl;sd;ed;ids;exc]
  wClause:();
  if[not all null ids;wClause,:enlist(in;`sym;enlist (),ids)];
  if[not all null (sd;ed); wClause,:enlist(within;`time;(enlist;sd;ed))];
  if[not all null exc; wClause,:enlist(in;`exchange;enlist (),exc)];
  $[`date in cols tbl;
  [wClause:enlist(within;`date;(enlist;`sd.date;`ed.date)),wClause;
      ?[tbl;wClause;0b;()]];
  [res:$[.z.D within (`date$sd;`date$ed); ?[tbl;wClause;0b;()];0#value tbl];
    `date xcols update date:.z.D from res]] };