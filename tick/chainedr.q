/ no dayend except 0#, can connect to tick.q or chainedtick.q tickerplant
/ q chainedr.q :5110 -p 5111 </dev/null >foo 2>&1 & 

/ q tick/chainedr.q [host]:port[:usr:pwd] [-p 5111] 

if[not "w"=first string .z.o;system "sleep 1"]

if[not system"p";system"p 5112"]

// define the realtime and recovery functions 

upd_realtime:{
    .debug.upd:(x;y);
    if[x in key `.rte;
        value[.rte x] @\: y
        ];
    }

upd_recovery:upd_realtime

// define callback functions for when a topic arrives
.rte.trade.vwap:{
    .debug.vwap:x;
    res:update 0f^vwap, 0f^accVol from (select latestVwap:size wavg price, latestAccVol: sum size by sym, exchange, time:time.minute from x) lj vwap;
    res:select sym, exchange, time, vwap:((accVol*vwap)+(latestAccVol*latestVwap))%(accVol+latestAccVol), accVol:accVol+latestAccVol from res;
    //update the vwaps table
    `vwap upsert res;
 }

.rte.trade.ohlcv:{
    .debug.ohlcv:x;
    res:update 0N^open, 0f^high, 0N^low, 0f^close, 0f^volume from (select latestOpen:first price, latestHigh:max price, latestLow:min price, latestClose:last price, latestVolume:sum size by sym, exchange, time:time.minute from x) lj ohlcv;
    res: update open: latestOpen from res where null open; 
    res:select sym, exchange, time, open: open, high: max (latestHigh;high), low:min(0w ^latestLow;0w ^ low), close:latestClose, volume: sum(volume;latestVolume) from res;
    `ohlcv upsert res;
  } 

// Call back function for the order table
.rte.order.agg:{.debug.x:x};

pub_data:{[x]    
    // find all records that are not the maximum per sym and exchange, publish and remove those rows
    if[count to_send:select from x where time < (max;time) fby ([]sym;exchange);
        .u.pub[x;0!to_send];
        delete from x where time < (max;time) fby ([]sym;exchange);
    ];
  }

/ get the chained ticker plant port, default is 5110
.u.x:.z.x,(count .z.x)_enlist":5000"
tph:hopen`$":",.u.x 0
.u.pub:{[t;x] neg[tph](`.u.upd;t;value flip x)}

/ end of day: maintain the last x records for vwap and ohlcv tables
.u.end:{@[`.;;-10000 sublist] each tables`.}

/ connect to tickerplant or chained ticker plant to subscribe to ALL tables
/(hopen`$":",.u.x 0)"(.u.sub[`;`];$[`m in key`.u;(`.u `m)\"`.u `i`L\";`.u `i`L])"
trh:hopen`$":",.u.x 0;
schemas:trh(`.u.sub;`;`);

/ init schema from TP and sync up from log file
/.u.rep:{(.[;();:;].)each x;if[null first y;:()];-11!y;}
{(.[;();:;].)each x} schemas
vwap:`sym`exchange`time xkey vwap
ohlcv:`sym`exchange`time xkey ohlcv
// get the log info, recover to that point, then swap to real time function
tp_log_info:trh({$[`m in key`.u;(`.u `m)"`.u `i`L";`.u `i`L]};::)
upd:upd_recovery
{if[null first x;:()];-11!x;} tp_log_info
// only keep the last records after recovery
vwap:select from vwap where time = (max;time) fby ([]sym;exchange)
ohlcv:select from ohlcv where time = (max;time) fby ([]sym;exchange)

// unsubscribe to the vwap and ohlcv tables as they are not being used for any streaming calcs
trh(`.u.del;`vwap`ohlcv;`);

// set upd to be the realtime version
upd:upd_realtime

// Call the publish data record every 1 minute using the inbuilt timer
.z.ts:{
    pub_data each `ohlcv`vwap;
 }
\t 60000
