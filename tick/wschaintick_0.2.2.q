/ can have -u; no end-of-day, no logfile, connect to master tickerplant
/ q chainedtick.q :5010 -p 5110 -t 1000 </dev/null >foo 2>&1 & 

/ q chainedtick.q [host]:port[:usr:pwd] [-p 5110] [-t N]

if[not system"p";system"p 5110"]

\l ../websocket/ws-server_0.2.2.q
\l ../websocket/ws-handler.q

.u.sub_and_set:{toSub:(.z.w)(`.u.sub;x;`);toSub[0] set toSub[1]};

if[system"t";
	 .z.ts:{.wsu.pub'[.wsu.t;value each .wsu.t];@[`.;.wsu.t;@[;`sym;`g#]0#]}; 
	  upd:{[t;x] t insert x;}]

if[not system"t";  
	   upd:{[t;x] .wsu.pub[t;x];}]

/ get the ticker plant port, default is 5010
.wsu.x:.z.x,(count .z.x)_enlist":5010"

/ init schema 
.wsu.rep:{(.[;();:;].)each x;}

/ connect to ticker plant for schema
.wsu.init .wsu.rep(.wsu.m:hopen`$":",.wsu.x 0)".u.sub[`;`]"

// Defining EOD function
.u.end:{[x]}

\
/test
>q tick.k
>q tick/ssl.q
>q chainedtick.k 

/run
>q tick.k sym  .   -p 5010       /tick
>q tick/r.k ::5010 -p 5011       /rdb
>q sym             -p 5012       /hdb
>q tick/ssl.q sym :5010          /feed
>q chainedtick.k   -p 5110     /chained tick 
