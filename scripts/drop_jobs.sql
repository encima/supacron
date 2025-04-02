DO $$
DECLARE 
    i INT;
BEGIN
    FOR i IN 1..1000 LOOP
        PERFORM cron.unschedule(i);
    END LOOP;
END;
$$;

DROP EXTENSION pg_cron;