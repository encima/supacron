CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA "pg_catalog";
CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA "extensions";

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