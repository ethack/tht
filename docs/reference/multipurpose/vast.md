

Setup
    curl -L -O https://storage.googleapis.com/tenzir-public-data/vast-static-builds/vast-static-latest.tar.gz
    mkdir vast
    tar -xC vast -f vast-static-latest.tar.gz 

    vast/bin/vast start
    # note: creates vast.db/ in pwd

Importing Zeek data.
https://github.com/tenzir/vast/blob/master/doc/cli/vast-import-zeek.md
https://docs.tenzir.com/vast/integrations/zeek


VAST supports parquet through Arrow?

VAST supports Sigma
https://docs.tenzir.com/vast/query-language/sigma
https://github.com/tenzir/vast/tree/master/plugins/sigma
Try running the Zeek rules

Has references to Sysmon. Can it import it?
https://docs.tenzir.com/vast/user-guides/custom-logs/
https://github.com/tenzir/vast/blob/master/schema/types/sysmon.schema
But still how? Sysmon log format will be evtx right? Looks like it expects it to come from json.
https://github.com/tenzir/vast/blob/65ecfc02192a2beb3dd38d403eeca28f4a4eb264/vast/integration/vast_integration_suite.yaml#L414-L415

VAST does not offer case-insensitive search :(
Doesn't seem to offer aggregations. Unless I'm just not getting it. It looks purely for extracting data and using other tools to do stuff with it.
But then how does it integrate with Sigma and handle sigma's aggregations?
Vast seems purely search and pivoting with no math operations either.

Can see a use case of outputting Zeek logs and piping to other places.
Maybe worth doing some benchmarks against `filter` and `zq` and `zq` with pre-processing into a columnar format.

The documentation really needs query examples. It focuses way too much on how things are implemented. You can tell it was written by comp scientists for comp scientists.

Examples:
- https://docs.tenzir.com/vast/quick-start/usage#data-export
- https://github.com/tenzir/vast/tree/master/examples/jupyter
- https://github.com/tenzir/vast/tree/master/doc/cli
- https://docs.tenzir.com/vast/user-guides/custom-logs/#querying-vast
- https://tenzir.com/blog/the-network-forensics-engine-of-the-future/ (watch the video)



Try reducing data using transforms or aggregations.
https://docs.tenzir.com/vast/features/transforms
https://tenzir.com/blog/release-v1.1/

Threat Bus sounds interesting, but I don't know how to use it.
https://tenzir.com/blog/release-2021-06-24/