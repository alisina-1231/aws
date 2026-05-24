 
 ## install awscurl 
 pip install awscurl

 ```sh
 awscurl--service es --region us-east-1 \
"https://search-my-test-domain-lcugkpnjfzdh4dakzdq3bpmd2a.us-east-1.es.amazonaws.com/_cluster/health?pretty"
```
# Output
{
  "cluster_name" : "Account_id:my-test-domain",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "discovered_master" : true,
  "discovered_cluster_manager" : true,
  "active_primary_shards" : 12,
  "active_shards" : 12,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}

```sh 
awscurl --service es --region us-east-1 \
-X PUT "https://search-my-test-domain-lcugkpnjfzdh4dakzdq3bpmd2a.us-east-1.es.amazonaws.com/users"
```
# Output
{"acknowledged":true,"shards_acknowledged":true,"index":"users"}

```sh
 awscurl --service es --region us-east-1 \
-X POST "https://search-my-test-domain-lcugkpnjfzdh4dakzdq3bpmd2a.us-east-1.es.amazonaws.com/users/_doc/1" \
-H "Content-Type: application/json" \
-d '{
  "name": "new",
  "role": "test",
  "country": "Afghanistan"
}'
```
# output

{"_index":"users","_id":"1","_version":1,"result":"created","_shards":{"total":2,"successful":1,"failed":0},"_seq_no":0,"_primary_term":1}

```sh
awscurl --service es --region us-east-1 \
"https://search-my-test-domain-lcugkpnjfzdh4dakzdq3bpmd2a.us-east-1.es.amazonaws.com/users/_search?pretty"
```
# Output
{
  "took" : 16,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 1,
      "relation" : "eq"
    },
    "max_score" : 1.0,
    "hits" : [
      {
        "_index" : "users",
        "_id" : "1",
        "_score" : 1.0,
        "_source" : {
          "name" : "new",
          "role" : "test",
          "country" : "Afghanistan"
        }
      }
    ]
  }
}
