use  nginx_log;
-- DROP TABLE IF EXISTS nginx_access_log;
CREATE TABLE IF NOT EXISTS nginx_access_log (
    remote_addr VARCHAR(30),
    remote_user VARCHAR(256),
    time_local DATETIME,
    request VARCHAR(4000),
    status SMALLINT,
    body_bytes_sent INT,
    http_referer VARCHAR(4000),
    http_user_agent VARCHAR(1000),
    http_x_forwarded_for VARCHAR(1000),
    host VARCHAR(256),
    server_name VARCHAR(256),
    request_time DECIMAL(20 , 3 ),
    upstream_addr VARCHAR(256),
    upstream_status SMALLINT,
    upstream_response_time DECIMAL(20 , 3 ),
    upstream_response_length INT,
    upstream_cache_status VARCHAR(256)
);



