PERFORM cron.schedule(
            'job_' || i,
            '* * * * *',
            $q$ select net.http_post(url:=get_decrypted_secret('sb_chain_function_rest_url'), headers:=jsonb_build_object('Authorization', get_decrypted_secret('sb_service_role_key')), timeout_milliseconds:=1000) $q$
        );