/Sample usage:
/q hdb.q C:/OnDiskDB/sym -p 5002
if[1>count .z.x;show"Supply directory of historical database";exit 0];
hdb:.z.x 0
/Mount the Historical Date Partitioned Database
@[{system"l ",x};hdb;{show "Error message - ",x;exit 0}]

// Define a function to call the select function API in an error trap
selectFunc:{[tbl;sd;ed;ids;exc]
    .debug.selectFunc:`tbl`sd`ed`ids`exc!(tbl;sd;ed;ids;exc);
    .[selectFuncAPI;(tbl;sd;ed;ids;exc);{0N!x;:()}]
 };
// Define a function to select from RDB and HDB based upon filters passed through the GET call
selectFuncAPI:{[tbl;sd;ed;ids;exc]
  wClause:(); // Initialize empty where clause
  if[not all null ids;wClause,:enlist(in;`sym;enlist (),ids)];  // If we have a filter based on symbols add it to the where clause
  if[not all null (sd;ed); wClause,:enlist(within;`time;(enlist;sd;ed))]; // If we have a filter based on time add it to the where clause
  if[not all null exc; wClause,:enlist(in;`exchange;enlist (),exc)]; // If we have a filter based on exchange add it to the where clause
  $[`date in cols tbl;    // If we are in the HDB
  [wClause:(enlist(within;`date;(enlist;`date$sd;`date$ed))),wClause; // Add date check to the where clause to select the date partition
      ?[tbl;wClause;0b;()]];  // Select from the table applying the conditions of the where clause
  [res:$[.z.d within (`date$sd;`date$ed); ?[tbl;wClause;0b;()];0#value tbl]; // Otherwise, we are in the RDB, if the date is not todays date in the RDB return an empty table, otherwise apply filters
    `date xcols update date:.z.d from res]] };  // Create a date column if in the RDB so the schemas match

selectFuncWithCols:{[tbl;sd;ed;ids;exc;columns]
    .debug.selectFuncWithCols:`tbl`sd`ed`ids`exc`columns!(tbl;sd;ed;ids;exc;columns);
    .[selectFuncWithColsAPI;(tbl;sd;ed;ids;exc;columns);{0N!x;:()}]
 };

selectFuncWithColsAPI:{[tbl;sd;ed;ids;exc;columns]
  wClause:();
  $[not count columns; colClause:();colClause:(columns except `date)!columns except `date]; // If no filters selected return all columns
  if[not all null ids;wClause,:enlist(in;`sym;enlist (),ids)];
  if[not all null (sd;ed); wClause,:enlist(within;`time;(enlist;sd;ed))];
  if[not all null exc; wClause,:enlist(in;`exchange;enlist (),exc)];
  $[`date in cols tbl;
  [wClause:(enlist(within;`date;(enlist;`date$sd;`date$ed))),wClause;
      ?[tbl;wClause;0b;colClause]];
  [res:$[.z.d within (`date$sd;`date$ed); ?[tbl;wClause;0b;colClause];0#value tbl];
    :$[`date in columns;`date xcols update date:.z.d from res;res]]] };
