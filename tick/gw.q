/ no dayend except 0#, can connect to tick.q or chainedtick.q tickerplant
/ q gw.q localhost:5002 localhost:5008 -p 511 </dev/null >foo 2>&1 & 

if[not system"p";system"p 5005"]

// Attempting to import the rest functionality
$["/"=last getenv`QHOME;runCommand:"l ",a:,[getenv`QHOME;"rest.q_"];runCommand:"l ",a:,[getenv`QHOME;"/rest.q_"]];

.gda.restEnabled:0b;

loadRestFunctionality:{
  system[x];
  .gda.restEnabled:1b;
  0N!"Successfully loaded in Rest";
 };

@[loadRestFunctionality;runCommand;{0N!"GDA Rest Failed to Load",x}];

// Opening IPC handles to the RDB and HDB
hdbHandle:`$":",.z.x 0;
rdbHandle:`$":",.z.x 1;

// vwap calculation
//TODO: This should be called somewhere other than in the dashboard
vwap_depth:{$[any z<=s:sums x;(deltas z & s) wavg y;0nf]};

// Defining a function to query data from within a Q session
getData:{[tbl;sd;ed;ids;exc]
  hdb:hdbHandle(`selectFunc;tbl;sd;ed;ids;exc);
  rdb:rdbHandle(`selectFunc;tbl;sd;ed;ids;exc);
  hdb,rdb };

// Defining correlation code
getCorrelation:{[exchange;startTime;endTime]
    data:getData[`vwap;startTime;endTime;`;exchange];
    res:select vwap:accVol wavg vwap by sym, time from data where not null vwap;
    times:([]time:asc distinct exec time from res);
    rack:times cross select distinct sym from res;
    col_order:exec sym from `mcap xdesc select mcap:sum vwap*accVol by sym from data where not null vwap;
    matrix:update fills vwap by sym from rack lj res;
    correlation:{x cor/:\: x} col_order xcols exec vwap by sym from matrix;
    areCols:(cols correlation) where {not all null value x} each -1_value update sym:key[correlation] from correlation;
    $[count areCols;:areCols!flip areCols!correlation[areCols][areCols];:()];
 }

// If the rest functionality has been imported successfully set registers
if[.gda.restEnabled;
  // Defining the function to be called from the REST endpoint
  .db.getDataREST:{
    .debug.x:x;
    tbl:x[`arg;`tbl];
    sd:$[(.z.p*0)~x[`arg;`sd];.z.p-00:01:00.000000000;x[`arg;`sd]];
    ed:$[(.z.p*0)~x[`arg;`ed];.z.p;x[`arg;`sd]];
    ids:x[`arg;`ids];
    exc:x[`arg;`exc];
    hdb:hdbHandle(`selectFunc;tbl;sd;ed;ids;exc);
    rdb:rdbHandle(`selectFunc;tbl;sd;ed;ids;exc);
    hdb,rdb };

  / Alias namespace for convenience, typically once at beginning of file
  .rest:.com_kx_rest;

  .rest.init enlist[`autoBind]!enlist[1b]; / Initialize
  // Adding in the register
  .rest.register[`get;
    "/getData";
    "API with format of getData";
    .db.getDataREST;
    .rest.reg.data[`tbl;-11h;0b;`trade;"Table to Query"],
      .rest.reg.data[`sd;-12h;0b;.z.p*0;"Start Date"],
          .rest.reg.data[`ed;-12h;0b;.z.p*0;"End Date"],
              .rest.reg.data[`ids;11h;0b;0#`;"Instruments to subscribe to"],
                  .rest.reg.data[`exc;11h;0b;0#`;"Exchange to subscribe to"]];

  ];
