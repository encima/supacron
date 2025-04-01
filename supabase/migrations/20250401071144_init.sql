CREATE EXTENSION IF NOT EXISTS pg_cron with schema 'pg_catalog';
CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA 'extensions';

CREATE OR REPLACE FUNCTION public.get_decrypted_secret(secret_name TEXT)
RETURNS TEXT AS $$
DECLARE
    secret TEXT := '';
BEGIN
    SELECT decrypted_secret
    INTO secret
    FROM vault.decrypted_secrets
    WHERE name = secret_name
    LIMIT 1;

    RETURN secret;
END;
$$ LANGUAGE plpgsql SECURITY INVOKER;

DO $$
DECLARE 
    i INT;
BEGIN
    FOR i IN 1..1000 LOOP
        PERFORM cron.schedule(
            'job_' || i,
            '* * * * *',
            $q$ select net.http_post(url:='https://loyal-shiner-30801.upstash.io/', headers:=jsonb_build_object('Authorization', get_decrypted_secret('upstash_redis_rest_token')), body:='["INCR", "many_crons"]', timeout_milliseconds:=1000) $q$
        );
    END LOOP;
END;
$$;