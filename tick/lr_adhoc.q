/ Adhoc writedown replacing RDB writedown for memory purposes
/ syntax:q lr_adhoc.q localhost:TP_PORT localhost:HDB_PORT -LOGFILE sym2022.06.21 
/ optional argument -LOGDIR
.z.zd:(17;2;6)
.u.opt:.Q.opt[.z.x]

if[not "w"=first string .z.o;system "sleep 1"];

// Define schema for replay tables
.lr.tables:`$();

/upd:insert;
upd:{[t;x] 
    if[t in .lr.tables;
        t insert x];
 }

/ get the ticker plant and history ports, defaults are 5010,5012
.u.x:.z.x,(count .z.x)_(":5010";":5012");


system"l sym.q"; // Load in the Schema from TP
@[;`sym;`g#]each tables[]; // Apply grouped attribute to sym column for each table
HDBDIR:(hopen `$":",.u.x 1)".z.x 0"; // Ask the HDB what it was passed on startup

/ end of day: save, clear, hdb reload
.u.end:{0N!"Starting EOD at: ",string[.z.p];t:.lr.tables;t@:where `g=attr each t@\:`sym;.Q.hdpf[`$":",.u.x 1;hsym `$HDBDIR;x;`sym];@[;`sym;`g#] each t;0N!"Finishing EOD at: ",string[.z.p];};

// Get the directory of the logfile from CL input (default to TP log directory if directory not specified)
LOGFILE:$[`LOGDIR in key .u.opt;
    (first .u.opt[`LOGDIR]),"/",first .u.opt[`LOGFILE];
        [
            DEFAULTLOGDIR:first ` vs (hopen `$":",.u.x 0)".u.L";
            hsym `$string[DEFAULTLOGDIR],"/",first .u.opt[`LOGFILE]
        ]
    ];

/.u.rep:{(.[;();:;].)each x;if[null first y;:()];-11!y;system "cd ",1_-10_string first reverse y};
.u.rep:{-11!x;system "cd ",HDBDIR;.u.end y;.Q.gc[]};
/ HARDCODE \cd if other than logdir/db

saveDate:"D"$3_first .u.opt[`LOGFILE];

\d .storedTables
system"l sym.q"; // Load in the Schema from TP
@[;`sym;`g#]each tables[]; // Apply grouped attribute to sym column for each table
\d .

requiredTables:(raze `order;`active_accounts`trade`ethereum`ohlcv`vwap);  // Tables we want
![`.;();0b;raze requiredTables];  // Delete from top namespace
{.lr.tables:y;{[toSet]toSet set .storedTables[toSet]}each y;.u.rep[x;z];![`.;();0b;y]}[LOGFILE;;saveDate] each requiredTables;
.Q.chk[hsym `$HDBDIR]