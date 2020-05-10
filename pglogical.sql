-- Install pglogical
CREATE EXTENSION pglogical;

-- Register a node into pglogical.
SELECT pglogical.create_node(node_name := 'node_name',dsn := 'host=host-addr dbname=postgres user=rep_user');

-- Create a pglogical replication set for inserts/updates only.
SELECT pglogical.create_replication_set(set_name := 'rep_set', replicate_insert := TRUE, replicate_update := TRUE,replicate_delete := FALSE, replicate_truncate := FALSE);

-- Register a table into an existing replication set.
SELECT pglogical.replication_set_add_table( 'rep_set', 'table_name');

-- Subscribe to a replication set from a subscriber node.
SELECT pglogical.create_subscription(subscription_name := 'sub_name', replication_sets := ARRAY['rep_set'], synchronize_data := TRUE,provider_dsn := 'host=origin_host dbname=postgres user=rep_user' );

-- Check health of replication set from subscriber node.
SELECT subscription_name, status, provider_node, replication_sets FROM pglogical.show_subscription_status('pgbench’);
