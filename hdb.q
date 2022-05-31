/Sample usage:
/q hdb.q C:/OnDiskDB/sym -p 5002
if[1>count .z.x;show"Supply directory of historical database";exit 0];
hdb:.z.x 0
/Mount the Historical Date Partitioned Database
@[{system"l ",x};hdb;{show "Error message - ",x;exit 0}]

// Define a function to call the select function API in an error trap
selectFunc:{[tbl;sd;ed;ids;exc]
    .[selectFuncAPI;(tbl;sd;ed;ids;exc);{-2!"Error selecting data: ",x;()}]
 };
// Define a function to select from RDB and HDB based upon filters passed through the GET call
selectFuncAPI:{[tbl;sd;ed;ids;exc]
  wClause:(); // Initialize empty where clause
  if[not all null ids;wClause,:enlist(in;`sym;enlist (),ids)];  // If we have a filter based on symbols add it to the where clause
  if[not all null (sd;ed); wClause,:enlist(within;`time;(enlist;sd;ed))]; // If we have a filter based on time add it to the where clause
  if[not all null exc; wClause,:enlist(in;`exchange;enlist (),exc)]; // If we have a filter based on exchange add it to the where clause
  $[`date in cols tbl;    // If we are in the HDB
  [wClause:enlist(within;`date;(enlist;`sd.date;`ed.date)),wClause; // Add date check to the where clause to select the date partition
      ?[tbl;wClause;0b;()]];  // Select from the table applying the conditions of the where clause
  [res:$[.z.D within (`date$sd;`date$ed); ?[tbl;wClause;0b;()];0#value tbl]; // Otherwise, we are in the RDB, if the date is not todays date in the RDB return an empty table, otherwise apply filters
    `date xcols update date:.z.D from res]] };  // Create a date column if in the RDB so the schemas match
