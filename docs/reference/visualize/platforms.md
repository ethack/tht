---
title: "Metabase"
date: 2021-05-29T11:44:06-05:00
draft: true
---

# Metabase
## Running

```
docker run -d -p 127.0.0.1:3000:3000 \
  --mount type=bind,source=/mnt/metabase/plugins,destination=/plugins \
  --mount type=bind,source=/mnt/metabase/data,destination=/metabase-data \
  -e MB_DB_FILE=/metabase-data/metabase.db \
  --network clickhouse \
  --name metabase metabase/metabase

```

Default Data Sources

Doesn't include Clickhouse or Elastic
https://github.com/enqueue/metabase-clickhouse-driver
Elastic is not supported. Commercial solution. https://panoply.io/
I guess we already have Kibana so it's probably overkill.
Hacky solution: https://github.com/metabase/metabase/issues/1300#issuecomment-308691067

Note: Metabase needs permission to write to plugins directory.

# Superset

Boo :( Doesn't support sqlite.
https://github.com/apache/superset/issues/9748#issuecomment-624536810

I was able to get it working, but manually editing the config.py inside the docker container.

Does support Elastic and Clickhouse.

## Running

```
docker run -d -p 8080:8088 --name superset apache/superset
```

```
docker exec -it superset superset fab create-admin \
               --username admin \
               --firstname Superset \
               --lastname Admin \
               --email admin@superset.com \
               --password admin
```

```
docker exec -it superset superset db upgrade
```

```
docker exec -it superset superset load_examples
```

```
docker exec -it superset superset init
```

https://hub.docker.com/r/apache/superset


Need to write your own version that includes your database drivers.

```dockerfile
FROM apache/superset
# Switching to root to install the required packages
USER root
# Example: installing the MySQL driver to connect to the metadata database
# if you prefer Postgres, you may want to use `psycopg2-binary` instead
RUN pip install mysqlclient
# Example: installing a driver to connect to Redshift
# Find which driver you need based on the analytics database
# you want to connect to here:
# https://superset.apache.org/docs/databases/installing-database-drivers
RUN pip install clickhouse-driver==0.2.0 && pip install clickhouse-sqlalchemy==0.1.6
# Switching back to using the `superset` user
USER superset
```

https://superset.apache.org/docs/databases/installing-database-drivers


# Kibana