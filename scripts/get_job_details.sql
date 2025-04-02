\! mkdir -p runs

\COPY net._http_response TO 'runs/http_response.csv' CSV HEADER;
\COPY cron.job_run_details TO 'runs/job_run_details.csv' CSV HEADER;