// Example of subscribing to KX Websocket End point using a dictionary
\l ./websocket/ws-client_0.2.2.q
upd:{0N!x}
h:.ws.open["ws://localhost:5110";`upd];
h .j.j `type`tables`syms!(`sub;`trade`vwap;`BTCUSD)
// can inspect the .wsu namespace in the CTP process to see how incoming tables are published