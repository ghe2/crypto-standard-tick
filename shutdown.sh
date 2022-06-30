#!/bin/bash
ps aux | grep ' feedhandler_bitmexBitfinex.q' | grep '5111'| grep -v grep | awk '{print $2}' | xargs -I {} kill -9 {}
ps aux | grep ' tick.q' | grep '5000'| grep -v grep | awk '{print $2}' | xargs -I {} kill -9 {}
ps aux | grep ' hdb.q' | grep '5002'| grep -v grep | awk '{print $2}' | xargs -I {} kill -9 {}
ps aux | grep ' r.q' | grep '5008'| grep -v grep | awk '{print $2}' | xargs -I {} kill -9 {}
ps aux | grep ' chainedr.q' | grep '5112'| grep -v grep | awk '{print $2}' | xargs -I {} kill -9 {}
ps aux | grep ' wschaintick_0.2.2.q' | grep '5110'| grep -v grep | awk '{print $2}' | xargs -I {} kill -9 {}
ps aux | grep ' gw.q' | grep '5005'| grep -v grep | awk '{print $2}' | xargs -I {} kill -9 {}
ps aux | grep ' sample/demo.q'| grep -v grep | awk '{print $2}' | xargs -I {} kill -9 {}
ps aux | grep ' dash.q' | grep '10001'| grep -v grep | awk '{print $2}' | xargs -I {} kill -9 {}