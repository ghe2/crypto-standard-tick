order: ([]`s#time:"p"$();`g#sym:`$();orderID:();side:`$();price:"f"$();size:"f"$();action:`$();orderType:`$();exchange:`$());
trade: ([]`s#time:"p"$();`g#sym:`$();orderID:();price:"f"$();tradeID:();side:`$();size:"f"$();exchange:`$());
vwap:([]sym:`$();exchange:`$();time:`minute$();vwap:`float$();accVol:`float$());
ohlcv:([]sym:`$();exchange:`$();time:`minute$();open:`float$();high:`float$();low:`float$();close:`float$();volume:`float$());
book: ([]`s#time:"p"$();`g#sym:`$();bids:();bidsizes:();asks:();asksizes:());