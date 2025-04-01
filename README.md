# Supacron

## What?

This is an example repository to provide a stress test the following features of Supabase:
- [Cron](https://supabase.com/docs/guides/cron)
- [Webhooks](https://supabase.com/docs/guides/database/webhooks)
- [Edge Functions](https://supabase.com/docs/guides/functions)

The aim of these tests are to determine the scale of using Jobs with Supabase in production. The tests have been split into 3 scenarios but they contain the same core concept: make a `POST` request to an endpoint on a minutely basis.

## Requirements

You need an endpoint to test against. We recommend using [Upstash Redis](https://upstash.com/docs/redis/overall/getstarted) as it provides a REST API and allows you to store logic. 
When you create your Redis on Upstash, you will need to save the following:
- `UPSTASH_REDIS_REST_TOKEN`
- `UPSTASH_REDIS_REST_URL`
to your database [Vault](https://supabase.com/docs/guides/database/vault).

Add them to your `.env` files using `dotenvx`

### For Production

1. `npx @dotenvx/dotenvx set UPSTASH_REDIS_REST_TOKEN "Bearer TOKEN" -f supabase/.env.production`
2. In `config.toml` add `upstash_redis_rest_token = "env(UPSTASH_REDIS_REST_TOKEN)"` under the `db.vault` section

### For Branches

1. `npx @dotenvx/dotenvx set UPSTASH_REDIS_REST_TOKEN "Bearer TOKEN" -f supabase/.env.preview`
2. In `config.toml` add `UPSTASH_REDIS_REST_TOKEN = "env(UPSTASH_REDIS_REST_TOKEN)"` under the `edge_runtime.secrets` section

Now you can run `npx supabase@latest secrets set --env-file supabase/env.keys`

## Scenarios

### `pg_cron`

Using the [Cron](https://supabase.green/dashboard/project/_/integrations/cron/jobs) integration, configure 1000 jobs to make a request to an endpoint every minute (where X is the number of jobs you want to run simultaneously)

The job is configured to call the Upstash endpoint directly with the `Authorization` header providing the `UPSTASH_REDIS_REST_TOKEN`. 

### `pg_cron` + Edge Functions

Using the [Cron](https://supabase.green/dashboard/project/_/integrations/cron/jobs) integration, configure 1000 jobs to call an Edge Function every minute

The job is configured to call an Edge Function with the `Authorization` header. The Edge Function invoked is the [redis-counter](supacron/supabase/functions/redis-counter/index.ts) function that makes a call to Upstash and needs the same secrets as above in your Edge Functions. 

### `pg_cron` + Single Chained Edge Functions

Using the [Cron](https://supabase.green/dashboard/project/_/integrations/cron/jobs) integration, configure a job to call an Edge Function every minute that chains to call X Edge Functions as [background tasks](https://supabase.com/docs/guides/functions/background-tasks)

This job is configured to call an Edge Function. The Edge Function invoked is the (main-chain)[supacron/supabase/functions/main-chain/index.ts] which invokes 1000 Edge Functions to make calls to Upstash.

## Monitoring

This repo uses two extensions and the monitoring of each of these can be done in their own schemas

### `pg_cron`

The `cron` schema has two tables:
1. `jobs` - This is all of the configured jobs for `pg_cron` to run, their frequency and the action they take
2. `job_run_details` - This contains the outcome of all of the jobs that have been executed by `pg_cron`

### `pg_net`

The `net` schema has two tables:
1. `_http_response` - This contains responses from calls made by `pg_net` in the last 6 hours
2. `http_request_queue` - This contains the queue of requests waiting to be made by `pg_net`

## Configuring

- You can customize some Postgres settings, such as `max_parallel_workers` using the [Supabase CLI](https://supabase.com/docs/guides/database/custom-postgres-config#cli-configurable-settings)
- Testing different values of X
- Running on different [instance sizes](https://supabase.com/docs/guides/platform/compute-and-disk)
