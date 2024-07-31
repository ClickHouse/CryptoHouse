-- tables schemas

CREATE DATABASE solana

-- solana.blocks

CREATE TABLE solana.blocks
(
    `block_hash` String,
    `block_timestamp` DateTime64(6),
    `height` Int64,
    `leader` String,
    `leader_reward` Decimal(38, 9),
    `previous_block_hash` String,
    `slot` Int64,
    `transaction_count` Int64
)
ENGINE = ReplacingMergeTree
PRIMARY KEY (block_timestamp, slot)
ORDER BY (block_timestamp, slot, block_hash)

-- solana.transactions

CREATE TABLE solana.transactions
(
    `accounts` Array(Tuple(pubkey String, signer Bool, writable Bool)),
    `balance_changes` Array(Tuple(account String, before Decimal(38, 9), after Decimal(38, 9))),
    `block_hash` String,
    `block_slot` Int64,
    `block_timestamp` DateTime64(6),
    `compute_units_consumed` Decimal(38, 9),
    `err` String,
    `fee` Decimal(38, 9),
    `index` Int64,
    `log_messages` Array(String),
    `post_token_balances` Array(Tuple(account_index Int64, mint String, owner String, amount Decimal(76, 38), decimals Int64)),
    `pre_token_balances` Array(Tuple(account_index Int64, mint String, owner String, amount Decimal(76, 38), decimals Int64)),
    `recent_block_hash` String,
    `signature` String,
    `status` String
)
ENGINE = ReplacingMergeTree
PRIMARY KEY (block_timestamp, block_slot)
ORDER BY (block_timestamp, block_slot, signature)

-- solana.accounts

CREATE TABLE solana.accounts
(
    `account_type` String,
    `authorized_voters` Array(Tuple(authorized_voter String, epoch Int64)),
    `authorized_withdrawer` String,
    `block_hash` String,
    `block_slot` Int64,
    `block_timestamp` DateTime64(6),
    `commission` Int64,
    `data` Array(Tuple(raw String, encoding String)),
    `epoch_credits` Array(Tuple(credits String, epoch Int64, previous_credits String)),
    `executable` Bool,
    `is_native` Bool,
    `lamports` Decimal(38, 9),
    `last_timestamp` Array(Tuple(slot Int64, timestamp DateTime64(6))),
    `mint` String,
    `node_pubkey` String,
    `owner` String,
    `prior_voters` Array(Tuple(authorized_pubkey String, epoch_of_last_authorized_switch Int64, target_epoch Int64)),
    `program` String,
    `program_data` String,
    `pubkey` String,
    `rent_epoch` Int64,
    `retrieval_timestamp` DateTime64(6),
    `root_slot` Int64,
    `space` Int64,
    `state` String,
    `token_amount` Decimal(38, 9),
    `token_amount_decimals` Int64,
    `tx_signature` String,
    `votes` Array(Tuple(confirmation_count Int64, slot Int64))
)
ENGINE = ReplacingMergeTree
PRIMARY KEY (block_timestamp, block_slot)
ORDER BY (block_timestamp, block_slot, pubkey, block_hash)

-- solana.tokens

CREATE TABLE solana.tokens
(
    `block_slot` Int64,
    `block_hash` String,
    `block_timestamp` DateTime64(6),
    `tx_signature` String,
    `retrieval_timestamp` DateTime64(6),
    `is_nft` Bool,
    `mint` String,
    `update_authority` String,
    `name` String,
    `symbol` String,
    `uri` String,
    `seller_fee_basis_points` Decimal(38, 9),
    `creators` Array(Tuple(address String, verified Bool, share Int64)),
    `primary_sale_happened` Bool,
    `is_mutable` Bool
)
ENGINE = ReplacingMergeTree
PRIMARY KEY (block_timestamp, block_slot)
ORDER BY (block_timestamp, block_slot, tx_signature, symbol)

-- solana.token_transfers

CREATE TABLE solana.token_transfers
(
    `authority` String,
    `block_hash` String,
    `block_slot` Int64,
    `block_timestamp` DateTime64(6),
    `decimals` Decimal(38, 9),
    `destination` String,
    `fee` Decimal(38, 9),
    `fee_decimals` Decimal(38, 9),
    `memo` String,
    `mint` String,
    `mint_authority` String,
    `source` String,
    `transfer_type` String,
    `tx_signature` String,
    `value` Decimal(38, 9),
    `id` String DEFAULT generateULID()
)
ENGINE = ReplacingMergeTree
PRIMARY KEY (block_timestamp, block_slot)
ORDER BY (block_timestamp, block_slot, id)

-- solana.block_rewards

CREATE TABLE solana.block_rewards
(
    `block_hash` String,
    `block_slot` Int64,
    `block_timestamp` DateTime64(6),
    `commission` Decimal(38, 9),
    `lamports` Decimal(38, 9),
    `post_balance` Decimal(38, 9),
    `pubkey` String,
    `reward_type` String
)
ENGINE = ReplacingMergeTree
PRIMARY KEY (block_timestamp, block_slot)
ORDER BY (block_timestamp, block_slot, pubkey)

-- materialized view for inserts

-- staging accounts

CREATE TABLE solana.stage_accounts
(
    `account_type` String,
    `authorized_voters` String,
    `authorized_withdrawer` String,
    `block_hash` String,
    `block_slot` Int64,
    `block_timestamp` DateTime64(6),
    `commission` Int64,
    `data` String,
    `epoch_credits` String,
    `executable` Bool,
    `is_native` Bool,
    `lamports` Decimal(38, 9),
    `last_timestamp` String,
    `mint` String,
    `node_pubkey` String,
    `owner` String,
    `prior_voters` String,
    `program` String,
    `program_data` String,
    `pubkey` String,
    `rent_epoch` Int64,
    `retrieval_timestamp` DateTime64(6),
    `root_slot` Int64,
    `space` Int64,
    `state` String,
    `token_amount` Decimal(38, 9),
    `token_amount_decimals` Int64,
    `tx_signature` String,
    `votes` String
)
ENGINE = Null

CREATE MATERIALIZED VIEW solana.stage_accounts_mv TO solana.accounts
(
    `account_type` String,
    `authorized_voters` Array(Tuple(String, Int64)),
    `authorized_withdrawer` String,
    `block_hash` String,
    `block_slot` Int64,
    `block_timestamp` DateTime64(6),
    `commission` Int64,
    `data` Array(Tuple(String, String)),
    `epoch_credits` Array(Tuple(String, Int64, String)),
    `executable` Bool,
    `is_native` Bool,
    `lamports` Decimal(38, 9),
    `last_timestamp` Array(Tuple(Int64, DateTime64(6))),
    `mint` String,
    `node_pubkey` String,
    `owner` String,
    `prior_voters` Array(Tuple(String, Int64, Int64)),
    `program` String,
    `program_data` String,
    `pubkey` String,
    `rent_epoch` Int64,
    `retrieval_timestamp` DateTime64(6),
    `root_slot` Int64,
    `space` Int64,
    `state` String,
    `token_amount` Decimal(38, 9),
    `token_amount_decimals` Int64,
    `tx_signature` String,
    `votes` Array(Tuple(Int64, Int64))
)
AS SELECT
    account_type,
    CAST(authorized_voters, 'Array(Tuple(String, Int64))') AS authorized_voters,
    authorized_withdrawer,
    block_hash,
    block_slot,
    block_timestamp,
    commission,
    JSONExtract(concat('[', data, ']'), 'Array(Tuple(String, String))') AS data,
    CAST(epoch_credits, 'Array(Tuple(String, Int64, String))') AS epoch_credits,
    executable,
    is_native,
    lamports,
    CAST(last_timestamp, 'Array(Tuple(Int64, DateTime64(6)))') AS last_timestamp,
    mint,
    node_pubkey,
    owner,
    CAST(prior_voters, 'Array(Tuple(String, Int64, Int64))') AS prior_voters,
    program,
    program_data,
    pubkey,
    rent_epoch,
    retrieval_timestamp,
    root_slot,
    space,
    state,
    token_amount,
    token_amount_decimals,
    tx_signature,
    CAST(votes, 'Array(Tuple(Int64, Int64))') AS votes
FROM solana.stage_accounts

-- stage transactions

CREATE TABLE solana.stage_transactions
(
    `accounts` String,
    `balance_changes` String,
    `block_hash` String,
    `block_slot` Int64,
    `block_timestamp` DateTime64(6),
    `compute_units_consumed` Decimal(38, 9),
    `err` String,
    `fee` Decimal(38, 9),
    `index` Int64,
    `log_messages` String,
    `pre_token_balances` String,
    `post_token_balances` String,
    `recent_block_hash` String,
    `signature` String,
    `status` String
)
ENGINE = Null

CREATE MATERIALIZED VIEW solana.stage_transactions_mv TO solana.transactions
(
    `accounts` Array(Tuple(String, Bool, Bool)),
    `balance_changes` Array(Tuple(String, Decimal(38, 9), Decimal(38, 9))),
    `block_hash` String,
    `block_slot` Int64,
    `block_timestamp` DateTime64(6),
    `compute_units_consumed` Decimal(38, 9),
    `err` String,
    `fee` Decimal(38, 9),
    `index` Int64,
    `log_messages` Array(String),
    `pre_token_balances` Array(Tuple(Int64, String, String, Decimal(76, 38), Int64)),
    `post_token_balances` Array(Tuple(Int64, String, String, Decimal(76, 38), Int64)),
    `recent_block_hash` String,
    `signature` String,
    `status` String
)
AS SELECT
    CAST(accounts, 'Array(Tuple(String, Bool, Bool))') AS accounts,
    CAST(balance_changes, 'Array(Tuple(String, Decimal(38, 9), Decimal(38, 9)))') AS balance_changes,
    block_hash,
    block_slot,
    block_timestamp,
    compute_units_consumed,
    err,
    fee,
    index,
    JSONExtract(log_messages, 'Array(String)') AS log_messages,
    CAST(pre_token_balances, 'Array(Tuple(Int64, String, String, Decimal(76, 38), Int64))') AS pre_token_balances,
    CAST(post_token_balances, 'Array(Tuple(Int64, String, String, Decimal(76, 38), Int64))') AS post_token_balances,
    recent_block_hash,
    signature,
    status
FROM solana.stage_transactions

-- materialized views for queries

-- non voting transactions

CREATE TABLE solana.transactions_non_voting
(
    `accounts` Array(Tuple(pubkey String, signer Bool, writable Bool)),
    `balance_changes` Array(Tuple(account String, before Decimal(38, 9), after Decimal(38, 9))),
    `block_hash` String,
    `block_slot` Int64,
    `block_timestamp` DateTime64(6),
    `compute_units_consumed` Decimal(38, 9),
    `err` String,
    `fee` Decimal(38, 9),
    `index` Int64,
    `log_messages` Array(String),
    `post_token_balances` Array(Tuple(account_index Int64, mint String, owner String, amount Decimal(76, 38), decimals Int64)),
    `pre_token_balances` Array(Tuple(account_index Int64, mint String, owner String, amount Decimal(76, 38), decimals Int64)),
    `recent_block_hash` String,
    `signature` String,
    `status` String
)
ENGINE = ReplacingMergeTree
PRIMARY KEY (block_timestamp, block_slot)


CREATE MATERIALIZED VIEW solana.transactions_non_voting_mv TO solana.transactions_non_voting
(
    `accounts` Array(Tuple(pubkey String, signer Bool, writable Bool)),
    `balance_changes` Array(Tuple(account String, before Decimal(38, 9), after Decimal(38, 9))),
    `block_hash` String,
    `block_slot` Int64,
    `block_timestamp` DateTime64(6),
    `compute_units_consumed` Decimal(38, 9),
    `err` String,
    `fee` Decimal(38, 9),
    `index` Int64,
    `log_messages` Array(String),
    `post_token_balances` Array(Tuple(account_index Int64, mint String, owner String, amount Decimal(76, 38), decimals Int64)),
    `pre_token_balances` Array(Tuple(account_index Int64, mint String, owner String, amount Decimal(76, 38), decimals Int64)),
    `recent_block_hash` String,
    `signature` String,
    `status` String
)
AS SELECT *
FROM solana.transactions
WHERE NOT arrayExists(account -> ((account.1) = 'Vote111111111111111111111111111111111111111'), accounts)


-- block_txn_counts_by_day

CREATE TABLE solana.block_txn_counts_by_day
(
    `day` Date,
    `block_count` AggregateFunction(uniqCombined(14), String),
    `txn_count` AggregateFunction(sum, Int64)
)
ENGINE = AggregatingMergeTree
ORDER BY day

CREATE MATERIALIZED VIEW solana.block_txn_counts_by_day_mv TO solana.block_txn_counts_by_day AS 
SELECT  toStartOfDay(block_timestamp) as day,
        uniqCombinedState(12)(block_hash) block_count,
        sumState(transaction_count) as txn_count
FROM blocks
GROUP BY day


-- creator_counts_by_day

CREATE TABLE solana.creator_counts_by_day
(
    `day` DateTime,
    `creator_count` AggregateFunction(uniqCombined(14), String),
    `token_count` AggregateFunction(uniqCombined(14), String)
)
ENGINE = AggregatingMergeTree
ORDER BY day

CREATE MATERIALIZED VIEW solana.creator_counts_by_day_mv TO solana.creator_counts_by_day AS
SELECT
  toStartOfDay(block_timestamp) as day,
  uniqCombinedState(14)(creators[1].1) AS creator_count,
  uniqCombinedState(14)(mint) as token_count
FROM
  solana.tokens
GROUP BY
  day

-- Daily fees & Daily signer count

CREATE TABLE solana.daily_fees_by_day (
    `day` DateTime,
    `avg_fee_sol` AggregateFunction(avg, Float64),
    `fee_sol` AggregateFunction(sum, Float64),
    `signer_count` AggregateFunction(uniqCombined(14), String)
) ENGINE = AggregatingMergeTree
ORDER BY (day)


CREATE MATERIALIZED VIEW solana.daily_fees_by_day_mv TO solana.daily_fees_by_day AS
SELECT
  toStartOfDay(block_timestamp) as day,
  avgState(fee / 1e9) AS avg_fee_sol,
  sumState(fee / 1e9) as fee_sol,
  uniqCombinedState(14)(accounts[1].1) as signer_count
FROM
  solana.transactions_non_voting
GROUP BY
  day

-- Daily txn count by type

CREATE TABLE solana.txn_count_by_type_by_day (
    `day` DateTime,
    `status` LowCardinality(String),
    `txn_count` AggregateFunction(uniqCombined(14), String)
) ENGINE = AggregatingMergeTree
ORDER BY (day, status)


CREATE MATERIALIZED VIEW solana.txn_count_by_type_by_day_mv TO solana.txn_count_by_type_by_day AS
SELECT
  toStartOfDay(block_timestamp) as day,
  status,
  uniqCombinedState(14)(signature) as txn_count
FROM
  solana.transactions
GROUP BY
  day, status

-- Daily txn count by type (non-voting)

CREATE TABLE solana.non_voting_txn_count_by_type_by_day (
    `day` DateTime,
    `status` LowCardinality(String),
    `txn_count` AggregateFunction(uniqCombined(14), String)
) ENGINE = AggregatingMergeTree
ORDER BY (day, status)


CREATE MATERIALIZED VIEW solana.non_voting_txn_count_by_type_by_day_mv TO solana.non_voting_txn_count_by_type_by_day AS
SELECT
  toStartOfDay(block_timestamp) as day,
  status,
  uniqCombinedState(14)(signature) as txn_count
FROM
  solana.transactions_non_voting
GROUP BY
  day, status


-- token transfer metrics

CREATE TABLE solana.token_transfer_metrics_by_day (
    `day` DateTime,
    `transfer_count` AggregateFunction(uniqCombined(14), String),
    `sender_count` AggregateFunction(uniqCombined(14), String),
    `reciever_count` AggregateFunction(uniqCombined(14), String),
) ENGINE = AggregatingMergeTree
ORDER BY day


CREATE MATERIALIZED VIEW solana.token_transfer_metrics_by_day_mv TO solana.token_transfer_metrics_by_day AS
SELECT
    toStartOfDay(block_timestamp) as day,
    uniqCombinedState(14)(tx_signature) as transfer_count,
    uniqCombinedState(14)(source) as sender_count,
    uniqCombinedState(14)(destination) as reciever_count
FROM
    solana.token_transfers
GROUP BY
    day

-- token transfer metrics by transfer_type

CREATE TABLE solana.token_transfer_metrics_by_type_by_day (
    `day` DateTime,
    `transfer_type` LowCardinality(String),
    `transfer_count` AggregateFunction(uniqCombined(14), String),
    `sender_count` AggregateFunction(uniqCombined(14), String),
    `reciever_count` AggregateFunction(uniqCombined(14), String),
) ENGINE = AggregatingMergeTree
ORDER BY (day, transfer_type)

CREATE MATERIALIZED VIEW solana.token_transfer_metrics_by_type_by_day_mv TO solana.token_transfer_metrics_by_type_by_day AS
SELECT
    toStartOfDay(block_timestamp) as day,
    transfer_type,
    uniqCombinedState(14)(tx_signature) as transfer_count,
    uniqCombinedState(14)(source) as sender_count,
    uniqCombinedState(14)(destination) as reciever_count
FROM
    solana.token_transfers
GROUP BY
    day, transfer_type

-- top token creators

CREATE TABLE solana.top_token_creators_by_day (
    `day` DateTime,
    `creator_address` String,
    `token_count` AggregateFunction(uniqCombined(14), String)
) ENGINE = AggregatingMergeTree
ORDER BY (day, creator_address)

CREATE MATERIALIZED VIEW solana.top_token_creators_by_day_mv TO solana.top_token_creators_by_day AS
SELECT
  toStartOfDay(block_timestamp) as day,
  creators[1].1 AS creator_address,
  uniqCombinedState(14)(mint) as token_count
FROM
  solana.tokens
GROUP BY
  day, creator_address

-- transaction counts

CREATE TABLE solana.transactions_per_day
(
    `date` Date,
    `count` Int64
)
ENGINE = SummingMergeTree
ORDER BY date

CREATE MATERIALIZED VIEW solana.transactions_per_day_mv TO solana.transactions_per_day AS
SELECT
  block_timestamp::Date as date, 
  count() AS count
FROM
  solana.transactions
GROUP BY date

-- non-voting transaction counts

CREATE TABLE solana.transactions_per_day_non_voting
(
    `date` Date,
    `count` Int64
)
ENGINE = SummingMergeTree
ORDER BY date

CREATE MATERIALIZED VIEW solana.transactions_per_day_non_voting_mv TO solana.transactions_per_day_non_voting AS
SELECT
  block_timestamp::Date as date, 
  count() AS count
FROM
  solana.transactions_non_voting
GROUP BY date


-- users and permissions


--crypto

CREATE USER crypto IDENTIFIED WITH double_sha1_password BY 'BE1BDEC0AA74B4DCB079943E70528096CCA985F8' DEFAULT ROLE NONE SETTINGS readonly = 1, add_http_cors_header = true, max_execution_time = 60., max_rows_to_read = 10000000000, max_bytes_to_read = 1000000000000, max_network_bandwidth = 25000000, max_memory_usage = 20000000000, max_bytes_before_external_group_by = 10000000000, max_result_rows = 10000, max_result_bytes = 10000000, result_overflow_mode = 'throw', read_overflow_mode = 'throw'

GRANT SELECT ON default.queries TO crypto
GRANT SELECT ON ethereum.* TO crypto
GRANT SELECT ON solana.* TO crypto
GRANT NONE TO crypto

CREATE SETTINGS PROFILE `crypto` SETTINGS readonly = 1, add_http_cors_header = true, max_execution_time = 60., max_rows_to_read = 10000000000, max_bytes_to_read = 1000000000000, max_network_bandwidth = 25000000, max_memory_usage = 20000000000, max_bytes_before_external_group_by = 10000000000, max_result_rows = 1000, max_result_bytes = 10000000, result_overflow_mode = 'break' CHANGEABLE_IN_READONLY, read_overflow_mode = 'break' CHANGEABLE_IN_READONLY, enable_http_compression = true, use_query_cache = true, query_cache_nondeterministic_function_handling = 'save' CHANGEABLE_IN_READONLY TO crypto

--- monitor

CREATE USER monitor IDENTIFIED WITH double_sha1_password BY 'BE1BDEC0AA74B4DCB079943E70528096CCA985F8' SETTINGS readonly = 1, add_http_cors_header = true, max_execution_time = 1., max_rows_to_read = 1000, max_bytes_to_read = 1000000000, max_network_bandwidth = 25000000, max_memory_usage = 1000000000, max_bytes_before_external_group_by = 10000000000, max_result_rows = 1000, max_result_bytes = 10000000, result_overflow_mode = 'break'

GRANT REMOTE ON *.* TO monitor
GRANT SELECT ON default.queries TO monitor
GRANT SELECT ON ethereum.* TO monitor
GRANT SELECT ON solana.* TO monitor
GRANT SELECT ON system.columns TO monitor
GRANT SELECT(elapsed, initial_user, query_id, read_bytes, read_rows, total_rows_approx) ON system.processes TO monitor
GRANT SELECT ON system.settings_profile_elements TO monitor
GRANT SELECT ON system.settings_profiles TO monitor

-- monitor_admin

CREATE USER monitor_admin IDENTIFIED WITH sha256_password --password omitted

GRANT KILL QUERY ON *.* TO monitor_admin;
GRANT SELECT(initial_address, query_id) ON system.processes TO monitor_admin;
GRANT SELECT ON system.settings_profile_elements TO monitor_admin;
GRANT SELECT ON system.settings_profiles TO monitor_admin;


-- quotas

CREATE QUOTA crypto KEYED BY ip_address FOR INTERVAL 1 hour MAX queries = 60, result_rows = 3000000000, read_rows = 3000000000000, execution_time = 6000 TO crypto
