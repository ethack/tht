---
title: "Sqlite"
date: 2021-05-29T10:40:02-05:00
draft: true
---

What am I even going to do with sqlite that I'm not already doing? It doesn't support native times or IP addresses. Sure I can do math, but is it going to be any better than what I already do with miller or zq? Especially when it's so much work getting zeek data in as the right types.
- It's just a way of introducting SQL as yet another query language. If you already know SQL then great, but if not is it worth it?
- Supposedly fast, but will it be faster than the columnar data storage or elastic?
- Virtual tables. Cool, I guess, but could also just save miller in a shell script.
- As a graph or document database? Maybe worth looking into.
  - https://github.com/dpapathanasiou/simple-graph
  - https://dgl.cx/2020/06/sqlite-json-support
- Web interface instead of cli. Might be attractive to some. But If going this far, maybe just use Elastic.
  - https://datasette.io/
  - Visualization: https://github.com/simonw/datasette-vega
  - Integrate with Jupyter (sort of): https://datasette.io/for/rapid-prototyping


- https://antonz.org/sqlite-is-not-a-toy-database/ - can read from json, csv
- https://github.com/nalgeon/sqlean
- https://github.com/simonw/csvs-to-sqlite

Loading Zeek logs

cat conn.log | z2c | sqlite3 conn.db -cmd ".mode csv" -cmd ".import /dev/stdin conn"

Sets all columns to `TEXT`. Which precludes all number based aggregations. Will need to set column types correctly. Likely with a wrapper script.
Need to provide shape file for sqlite
Could also do with the csvs-to-sqlite project
Maybe read in with zq to get data types and convert to table definition.


cat conn.log | tail -n +7 | sed -e '0,/^#fields\t/s///' | tail -n +1 | sqlite3 conn.db -cmd ".mode tabs" -cmd ".import /dev/stdin conn"

cat conn.log | z2t | sqlite3 conn.db -cmd ".mode tabs" -cmd ".import /dev/stdin conn"

Oh shit. This installs pandas and numpy. No wonder the size jumped.
$ csvs-to-sqlite conn.csv conn1.db
Loaded 1 dataframes
Created conn1.db from 1 CSV file

Trying this basically failed. It took way too long.
csvs-to-sqlite --replace-tables -dt ts conn.csv conn1.db

Trying it with fewer entries worked. But ts is still a "TEXT" type instead of date. Oh, I guess that's the right type.
$ csvs-to-sqlite --replace-tables -dt ts conn1000.csv conn1.db
Loaded 1 dataframes
Added 1 CSV file to conn1.db

Wouldn't I want an index on basically everything?
$ csvs-to-sqlite --replace-tables -dt ts -i "id.orig_h" -i "id.resp_h" -i "id.orig_h","id.resp_h" conn1000.csv conn1.db


CREATE TABLE IF NOT EXISTS "conn1000" (
"_path" TEXT,
  "ts" TEXT,
  "uid" TEXT,
  "id.orig_h" TEXT,
  "id.orig_p" INTEGER,
  "id.resp_h" TEXT,
  "id.resp_p" INTEGER,
  "proto" TEXT,
  "service" TEXT,
  "duration" REAL,
  "orig_bytes" INTEGER,
  "resp_bytes" INTEGER,
  "conn_state" TEXT,
  "local_orig" INTEGER,
  "local_resp" INTEGER,
  "missed_bytes" INTEGER,
  "history" TEXT,
  "orig_pkts" INTEGER,
  "orig_ip_bytes" INTEGER,
  "resp_pkts" INTEGER,
  "resp_ip_bytes" INTEGER,
  "tunnel_parents" INTEGER
);
CREATE INDEX ["conn1000_id.orig_h"] ON [conn1000]("id.orig_h");
CREATE INDEX ["conn1000_id.resp_h"] ON [conn1000]("id.resp_h");
CREATE INDEX ["conn1000_id.orig_h_id.resp_h"] ON [conn1000]("id.orig_h", "id.resp_h");

This command might be useful for developing a create table dynamically.
$ head -9 conn1000.log | zq -f zjson - | jq '.schema'
https://github.com/brimdata/zed/blob/main/zeek/Data-Type-Compatibility.md

Another option (oh, it's the same author as csvs-to-sqlite):
https://sqlite-utils.datasette.io/en/stable/cli.html#inserting-csv-or-tsv-data
Not sure if this will auto-detect datatypes but it looks like it might.
https://datasette.io/plugins/datasette-upload-csvs

Holy crap, can just do a demo in a browser.
https://docs.datasette.io/en/latest/getting_started.html#getting-started-glitch
Go here:
https://glitch.com/edit/#!/remix/datasette-csvs
Drag and drop a CSV to upload.
Then click Show->In New Window.
Just imports everything into string columns though. Means can't do greater or less than on ports, bytes, etc. Haha! But it wasn't hard to add csvs-to-sqlite and modify the project to use that instead. Now number columns are correct!
No graphing plugins. Though there's one already in the requirements file that's commented out. If I enrich data with geo using zannotate this could get really interesting.
        #sqlite-utils insert .data/data.db ${f%.*} $f --csv
        csvs-to-sqlite $f .data/data.db


## JSON

Use zq with shaper to convert back to richly typed Zeek format and then convert using csv.

Actually, this is pretty cool.
https://dgl.cx/2020/06/sqlite-json-support

This might actually be useful for tying Zeek and Sysmon together or doing process trees.
https://github.com/dpapathanasiou/simple-graph/tree/main/python
https://www.youtube.com/watch?v=98MrgfTFeMo
Could also use an actual graph database.
https://pypi.org/project/bulbs/

https://www.sqlitetutorial.net/sqlite-cheat-sheet/