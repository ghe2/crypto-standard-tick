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

.u.sub_and_set:{toSub:(.z.w)(`.u.sub;x;`);toSub[0] set toSub[1]};

//////////////////////////////////////////////////// Order Book Logic /////////////////////////////////////////////////////////

book: ([]`s#time:"p"$();`g#sym:`$();bids:();bidsizes:();asks:();asksizes:());
/ lastBookBySym:enlist[`]!enlist `bidbook`askbook!(()!();()!()); 
lastBookBySymExch:([sym:`$();exchange:`$()]bidbook:();askbook:());
`lastBookBySymExch upsert (`;`;()!();()!()); 

bookbuilder:{[x;y]
    .debug.xy:(x;y);
    $[not y 0;x;
        $[
            `insert=y 4;
                x,enlist[y 1]! enlist y 2 3;
            `update=y 4;
                $[any (y 1) in key x;
                    [
                        //update size
                        a:.[x;(y 1;1);:;y 3];
                        //update price if the price col is not null
                        $[0n<>y 2;.[a;(y 1;0);:;y 2];a]
                    ];
                    x,enlist[y 1]! enlist y 2 3
                ];  
            `remove=y 4;
                $[any (y 1) in key x;
                    enlist[y 1] _ x;
                    x];
            x
        ]
    ]
    };
 
generateOrderbook:{[newOrder]
    .debug.generateOrderBook:`newOrder`lastBookBySym!(newOrder;lastBookBySymExch);
    //create the books based on the last book state
    / books:update bidbook:bookbuilder\[lastBookBySym[first sym]`bidbook;flip (side like "bid";orderID;price;size;action)],askbook:bookbuilder\[lastBookBySym[first sym]`askbook;flip (side like "ask";orderID;price;size;action)] by sym from newOrder;
    books:update bidbook:bookbuilder\[@[lastBookBySymExch;(first sym; first exchange)]`bidbook;flip (side like "bid";orderID;price;size;action)],askbook:bookbuilder\[@[lastBookBySymExch;(first sym; first exchange)]`askbook;flip (side like "ask";orderID;price;size;action)] by sym, exchange from newOrder;

    //store the latest book statex
    .debug.books1:books;
    / lastBookBySym,:exec last bidbook,last askbook by sym from books;
    lastBookBySymExch,:exec last bidbook,last askbook by sym, exchange from books;
    //generate the orderbook 
    books:select time,sym,exchange,bids:(value each bidbook)[;;0],bidsizes:(value each bidbook)[;;1],asks:(value each askbook)[;;0],asksizes:(value each askbook)[;;1] from books;
    books:update bids:desc each distinct each bids,bidsizes:{sum each x group y}'[bidsizes;bids] @' desc each distinct each bids,asks:asc each distinct each asks,asksizes:{sum each x group y}'[asksizes;asks] @' asc each distinct each asks from books

    };

.rte.order.orderbook:{
    .debug.orderbook:x;
    books:generateOrderbook[x];
    .u.pub[`book;books]
 }

//////////////////////////////////////////////////// End Order Book Logic /////////////////////////////////////////////////////

// define callback functions for when a topic arrives
.rte.trade.vwap:{
    .debug.vwap:x;
    res:update 0f^vwap, 0f^accVol from (select latestVwap:size wavg price, latestAccVol: sum size by sym, exchange, time:time.minute from x) lj (update time:time.minute from vwap);
    res:select sym, exchange, time, vwap:((accVol*vwap)+(latestAccVol*latestVwap))%(accVol+latestAccVol), accVol:accVol+latestAccVol from res;
    //update the vwaps table
    res:update time:time+.z.d from res;
    `vwap upsert res;
 }

.rte.trade.ohlcv:{
    .debug.ohlcv:x;
    res:update 0N^open, 0f^high, 0N^low, 0f^close, 0f^volume from (select latestOpen:first price, latestHigh:max price, latestLow:min price, latestClose:last price, latestVolume:sum size by sym, exchange, time:time.minute from x) lj (update time:time.minute from ohlcv);
    res: update open: latestOpen from res where null open; 
    res:select sym, exchange, time, open: open, high: max (latestHigh;high), low:min(0w ^latestLow;0w ^ low), close:latestClose, volume: sum(volume;latestVolume) from res;
    res:update time:time+.z.d from res;
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
