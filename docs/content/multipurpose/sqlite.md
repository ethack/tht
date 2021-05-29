---
title: "Sqlite"
date: 2021-05-29T10:40:02-05:00
draft: true
---


    - https://antonz.org/sqlite-is-not-a-toy-database/ - can read from json, csv
    - https://github.com/nalgeon/sqlean

Loading Zeek logs

cat conn.log | z2c | sqlite3 conn.db -cmd ".mode csv" -cmd ".import /dev/stdin conn"

Sets all columns to `TEXT`. Which precludes all number based aggregations. Will need to set column types correctly. Likely with a wrapper script.

cat conn.log | tail -n +7 | sed -e '0,/^#fields\t/s///' | tail -n +1 | sqlite3 conn.db -cmd ".mode tabs" -cmd ".import /dev/stdin conn"

cat conn.log | z2t | sqlite3 conn.db -cmd ".mode tabs" -cmd ".import /dev/stdin conn"

## JSON


