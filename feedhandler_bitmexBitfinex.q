\l ./websocket/ws-client_0.2.2.q
/conda install -c jmcmurray ws-client ws-server
/.utl.require"ws-client";

.debug.loggingOn:0b;

h:@[hopen;(`$":localhost:5000";10000);0i];
pub:{$[h=0;
        neg[h](`upd   ;x;y);
        $[0h~type y;neg[h](`.u.upd;x;y);neg[h](`.u.upd;x;value flip y)]
        ]};

upd:upsert;

//initialise displaying tables
order: ([]`s#time:"p"$();`g#sym:`$();orderID:();side:`$();price:"f"$();size:"f"$();action:`$();orderType:`$();exchange:());
trade: ([]`s#time:"p"$();`g#sym:`$();orderID:();price:"f"$();tradeID:();side:`$();size:"f"$();exchange:`$());
book: ([]`s#time:"p"$();`g#sym:`$();bids:();bidsizes:();asks:();asksizes:());
lastBookBySym:enlist[`]!enlist `bidbook`askbook!(()!();()!());
connChkTbl:([exchange:`$();feed:`$()]`s#time:"p"$());

/value mapping 
BuySellDict:("Buy";"Sell")!(`bid;`ask);

//create the ws subscription table
hostsToConnect:([]hostQuery:();request:();exchange:`$();feed:`$();callbackFunc:`$());
//add BITFINEX websockets
`hostsToConnect upsert `hostQuery`request`exchange`feed`callbackFunc!("wss://api-pub.bitfinex.com/ws/2";`event`channel`pair`prec!("subscribe";"book";"tETHUSD";"R0");`bitfinex;`order;`.bitfinex.order.upd);
`hostsToConnect upsert `hostQuery`request`exchange`feed`callbackFunc!("wss://api-pub.bitfinex.com/ws/2";`event`channel`pair`prec!("subscribe";"trades";"tETHUSD";"R0");`bitfinex;`trade;`.bitfinex.trade.upd);
//add BitMEX order websockets 
`hostsToConnect upsert `hostQuery`request`exchange`feed`callbackFunc!("wss://ws.bitmex.com/realtime";`op`args!("subscribe";"orderBookL2_25:XBTUSD");`bitmex;`order;`.bitmex.upd);
`hostsToConnect upsert `hostQuery`request`exchange`feed`callbackFunc!("wss://ws.bitmex.com/realtime";`op`args!("subscribe";"orderBookL2_25:ETHUSD");`bitmex;`order;`.bitmex.upd);

//add BitMex trade websockets
`hostsToConnect upsert `hostQuery`request`exchange`feed`callbackFunc!("wss://ws.bitmex.com/realtime";`op`args!("subscribe";"trade:ETHUSD");`bitmex;`trade;`.bitmex.upd);
`hostsToConnect upsert `hostQuery`request`exchange`feed`callbackFunc!("wss://ws.bitmex.com/realtime";`op`args!("subscribe";"trade:XBTUSD");`bitmex;`trade;`.bitmex.upd);

///////////////////////////// Uncomment to increase the trade syms /////////////////////////////////
/ `hostsToConnect upsert `hostQuery`request`exchange`feed`callbackFunc!("wss://ws.bitmex.com/realtime";`op`args!("subscribe";"trade");`bitmex;`trade;`.bitmex.upd);
////////////////////////////////////////////////////////////////////////////////////////////////////

//add record ID
hostsToConnect:update ws:1+til count i from hostsToConnect;


//bitmex trades and orders callback function 
.bitmex.upd:{
    d:.j.k x;.debug.bitmex.d:d; //0N!d;
    if[`table`action`data ~ key d;
        if[d[`table] like "orderBookL2*";
            $[d[`action] like "insert";
                [.debug.bitmex.i:d;new:select time:"p"$"Z"$timestamp,sym:`$symbol,orderID:string "j"$id,side:BuySellDict[side],price,size,action:`insert,orderType:`unknown,exchange:`bitmex from d`data];
                d[`action] like "update";
                [.debug.bitmex.u:d;new:select time:"p"$"Z"$timestamp,sym:`$symbol,orderID:string "j"$id,side:BuySellDict[side],price:0nf,size,action:`update,orderType:`unknown,exchange:`bitmex from d`data];
                d[`action] like "delete";
                [.debug.bitmex.e:d;new:select time:"p"$"Z"$timestamp,sym:`$symbol,orderID:string "j"$id,side:BuySellDict[side],price:0n,size:0n,action:`remove,orderType:`unknown,exchange:`bitmex from d`data];
                d[`action] like "partial";
                [.debug.bitmex.p:d;new:select time:"p"$"Z"$timestamp,sym:`$symbol,orderID:string "j"$id,side:BuySellDict[side],price:0n,size:0n,action:`partial,orderType:`unknown,exchange:`bitmex from d`data];
                    .debug.bitmex.a:d;
                ];

            //debug variable to see new records
            .debug.bitmex.new:new;
            if[.debug.loggingOn;0N!"order pub start"];
            //publish to TP - order table
            pub[`order;new];
            if[.debug.loggingOn;0N!"order pub end"];
            //update record in the connection check table
            upsert[`connChkTbl;(`bitmex;`order;.z.p)];
            ];
        if[d[`table] like "trade";
            $[d[`action] like "insert";
                [.debug.bitmex.trade.i:d;
                    newTrade:select time:("p"$"Z"$timestamp),sym:`$symbol,orderID:" ",price,tradeID:trdMatchID,side:BuySellDict[side],"f"$size,exchange:`bitmex from d`data;
                    .debug.bitmex.newTrade:newTrade;
                    //publish to TP - trade table
                    if[.debug.loggingOn;0N!"start pub trade"];
                    / pub[`trade;value flip newTrade];
                    pub[`trade;newTrade];
                    if[.debug.loggingOn;0N!"end pub trade"];
                    //update record in the connection check table
                    upsert[`connChkTbl;(`bitmex;`trade;.z.p)];
                    ];
              d[`action] like "partial";
                    .debug.bitmex.trade.p:d;
                    .debug.bitmex.trade.a:d;
            ];
        ]
    ];
  };

//Bitfinex order books callback function 
.bitfinex.order.upd:{
    d:.j.k x;.debug.bitfinex.d:d; //0N!d;

    //capture the subscription sym
    if[(99h~type d);
        targetKey:`event`channel`chanId`symbol`prec`freq`len`pair;
        if[targetKey~key d;
            .debug.bitfinex.ordSubInfo:d;
            .bitfinex.ordSubSym:`$d[`pair]
        ];
        :()
    ];

    //order events 
    if[(3~count d[1]) and 2~count d;
        .debug.bitfinex.order:d;

        //if AMOUNT > 0 then bid else ask; Funding: if AMOUNT < 0 then bid else ask
        //when PRICE > 0 then you have to add or update the order
        //when PRICE = 0 then you have to delete the order
        rd:raze d;
        newOrder:(.z.p;.bitfinex.ordSubSym;(string "j"$rd[1]);$[0<rd[3];`bid;`ask];abs "f"$rd[2];abs "f"$rd[3];$[0<rd[2];`update;`remove];`unknown;`bitfinex);

        //publish to TP - order table
        pub[`order;newOrder];
        //update record in the connection check table
        upsert[`connChkTbl;(`bitfinex;`order;.z.p)];
    ];
    };

//Bitfinex trades callback function 
.bitfinex.trade.upd:{
    d:.j.k x;.debug.bitfinex.dt:d; //0N!d;

    //capture the subscription sym
    if[(99h~type d);
        targetKey:`event`channel`chanId`symbol`pair;
        if[targetKey~key d;
            .debug.bitfinex.trdSubInfo:d;
            .bitfinex.trdSubSym:`$d[`pair]
        ];
        :()
    ];

    //trade transactions
    if[(4~count d[2]) and 3~count d;
        .debug.bitfinex.trade:d;
        newTrade:(.z.p;.bitfinex.trdSubSym;" ";"f"$d[2][3];string "j"$d[2][0];$[0<d[2][2];`bid;`ask]; abs "f"$d[2][2];`bitfinex);

        //publish to TP - trade table
        pub[`trade;newTrade]

        //update record in the connection check table
        upsert[`connChkTbl;(`bitfinex;`trade;.z.p)];
    ];
    };

//establish the ws connection
establishWS:{
    .debug.x:x;
    hostQuery:x[`hostQuery];
    request:x[`request];
    callbackFunc:x[`callbackFunc];

    //pass the exchange value to the gda upd func
    if[request[`feed] like "normalised";
        callbackFunc set .gdaNormalised.upd[;request[`exchange]]
    ];

    if[request[`feed] like "trades";
        callbackFunc set .gdaTrades.upd[;request[`exchange]]
    ];

    if[request[`feed] like "raw";
        callbackFunc set .gdaRaw.upd[;request[`exchange]]
    ];

    currentExchange:$[`op`exchange`feed~key request;string request[`exchange];string (` vs callbackFunc)[1]];
    currentFeed:$[`op`exchange`feed~key request;request[`feed];$["" like request[`channel];request[`args];request[`channel]]];

    //connect to the websocket
    0N!"Connecting the ",currentExchange," ",currentFeed," websocket at ",string .z.z;
    handle: `$".ws.h",string x[`ws];
    handle set .ws.open[hostQuery;callbackFunc];

    //send request to the websocket
    if[0<count request; (get handle) .j.j request];
    0N!currentExchange," ",currentFeed," websocket is connected at ",string .z.z;
    };

//connect to the websockets
establishWS each hostsToConnect;

//open the websocket and check the connection status 
connectionCheck:{[]
    0N!"Checking the websocket connection status";
    //Reconnect after 10 minutes if no new records are being updated
    reconnectList: select from connChkTbl where time<(.z.p-00:10:00); 
    if[0<count reconnectList;
        feedList: exec feed from reconnectList;
        exchangeList: exec exchange from reconnectList;
        hostToReconnect:select from hostsToConnect where feed in feedList,exchange in exchangeList;
        callBacksToDisconnect:exec callbackFunc from hostToReconnect;
        handlesToDisconnect:exec h from .ws.w where callback in callBacksToDisconnect;
        .ws.close each handlesToDisconnect;
        {0N!x[0]," ",x[1]," WS Not connected!.. Reconnecting at ",string .z.z}each string (exec exchange from hostToReconnect),'(exec feed from hostToReconnect);
        establishWS each hostToReconnect
    ];
    
    if[0~count reconnectList;
        0N!"Websocket connections are all secure"
    ];
    };

/connection check every 10 min
.z.ts:{connectionCheck[]};
\t 600000
