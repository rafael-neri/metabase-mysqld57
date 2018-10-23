#!/bin/sh
exec ruby -S -x $0 "$@"
#! ruby

require_relative 'nginx_log_parser'

start_time = Time.now

def parse_file (file)
  parser = Application::NginxLogParser.new(file)
  parser.parse
end

def skip_log_file_parse?
  ARGV.include?('-s') || ARGV.include?('--skip-log-parse')
end

def to_i_for_sql (s)
  s.nil? ? 'null' : (s.kind_of?(Integer) ? s_to_i : 'null')
end

def to_f_for_sql (s)
  s.nil? ? 'null' : (s.kind_of?(Float) ? s.to_f : 'null')
end

def to_s_for_sql (s)
  s.nil? ? 'null' : "'#{s.to_s}'"
end

def generate_sql_for_mysql(data)
  q = ''
  data.each do |d|
    s = "insert into nginx_access_log values ("
    s << to_s_for_sql(d[:remote_addr])
    s << ',' + to_s_for_sql(d[:remote_user])
    s << ',' + to_s_for_sql(d[:time_local])
    s << ',' + to_s_for_sql(d[:request])
    s << ',' + to_i_for_sql(d[:status])
    s << ',' + to_i_for_sql(d[:body_bytes_sent])
    s << ',' + to_s_for_sql(d[:http_referer])
    s << ',' + to_s_for_sql(d[:http_user_agent])
    s << ',' + to_s_for_sql(d[:http_x_forwarded_for])
    s << ',' + to_s_for_sql(d[:host])
    s << ',' + to_s_for_sql(d[:server_name])
    s << ',' + to_f_for_sql(d[:request_time])
    s << ',' + to_s_for_sql(d[:upstream_addr])
    s << ',' + to_i_for_sql(d[:upstream_status])
    s << ',' + to_f_for_sql(d[:upstream_response_time])
    s << ',' + to_i_for_sql(d[:upstream_response_length])
    s << ',' + to_s_for_sql(d[:upstream_cache_status])
    s << ");"
    s << "\n"
    q << s
  end
  q
end

data = nil;
unless skip_log_file_parse? then
  ARGV.each do |file|
    print file
    next if file.start_with?('-')
    data = parse_file(file)
    sql = generate_sql_for_mysql(data)
    File.open(file + ".sql", "w") do |f|
      f.puts(sql)
    end
    puts " -> #{file}.sql"
  end
end

end_time = Time.now
runtime = (end_time - start_time)
puts "\nExecuted in %s seconds" % runtime

