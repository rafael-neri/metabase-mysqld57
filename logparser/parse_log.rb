#!/bin/sh
exec ruby -S -x $0 "$@"
#! ruby

require_relative 'nginx_log_parser'
require 'active_record'

start_time = Time.now

def parse_file (file)
  parser = Application::NginxLogParser.new(file)
  parser.parse
end

def skip_log_file_parse?
  ARGV.include?('-s') || ARGV.include?('--skip-log-parse')
end

def to_i_for_sql (s)
  (s.nil? || s.eql?('-')) ? nil : s.to_i
end

def to_f_for_sql (s)
  (s.nil? || s.eql?('-')) ? nil : s.to_f
end

def to_s_for_sql (s)
  s.nil? ? nil : s.to_s
end

def generate_sql_for_mysql(data)
  q = []
  data.each do |d|
    s = ["insert into nginx_access_log values (#{Array.new(17, '?').join(',')});",

         d[:remote_addr],
         d[:remote_user],
         d[:time_local],
         d[:request],
         to_i_for_sql(d[:status]),

         to_i_for_sql(d[:body_bytes_sent]),
         d[:http_referer],
         d[:http_user_agent],
         d[:http_x_forwarded_for],
         d[:host],

         d[:server_name],
         to_f_for_sql(d[:request_time]),
         d[:upstream_addr],
         to_i_for_sql(d[:upstream_status]),
         to_f_for_sql(d[:upstream_response_time]),

         to_i_for_sql(d[:upstream_response_length]),
         d[:upstream_cache_status]
    ]
    q << ActiveRecord::Base.send(:sanitize_sql_array, s)
  end
  q
end


ActiveRecord::Base.establish_connection(
  :adapter => 'mysql2',
  :host => '127.0.0.1',
  :port => 3306,
  :username => 'root',
  :password => 'root',
  :database => 'nginx_log',
  :encoding => 'utf8',
  :timeout => 5000
)

# data = nil;
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

