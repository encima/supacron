DO $$
DECLARE 
    i INT;
BEGIN
    FOR i IN 1..1000 LOOP
        PERFORM cron.schedule(
            'job_' || i,
            '* * * * *',
            $q$ select net.http_post(url:=get_decrypted_secret('upstash_redis_rest_url'), headers:=jsonb_build_object('Authorization', get_decrypted_secret('upstash_redis_rest_token')), body:='["INCR", "key1"]', timeout_milliseconds:=1000) $q$
        );
    END LOOP;
END;
$$;