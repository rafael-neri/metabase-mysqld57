require 'pry'
require 'json'
require 'uri'
require 'time'

module Application
  class NginxLogParser

    # see: https://github.com/nginxinc/nginx-amplify-doc/blob/master/amplify-guide.md#additional-nginx-metrics
    LOG_FORMAT = /
        ([\d\.]+)\s+
        \-\s+
        ([^\s]+)\s+
        \[([^\]]+)\]\s+
        "([^"]*)"\s+
        ([\d]+)\s+
        ([\d]+)\s+
        "([^"]*)"\s+
        "([^"]*)"\s+
        "([^"]*)"\s+
        "([^"]*)"\s+
        sn="([^"]*)"\s+
        rt=([\d\.]+)\s+
        ua="([^"]*)"\s+
        us="([^"]*)"\s+
        ut="([^"]*)"\s+
        ul="([^"]*)"\s+
        cs=([^\s]+)
        (.*)
      /xi

    REQUEST_FORMAT = [
      :remote_addr,
      :remote_user,
      :time_local,
      :request,
      :status,
      :body_bytes_sent,
      :http_referer,
      :http_user_agent,
      :http_x_forwarded_for,
      :host, :server_name,
      :request_time,
      :upstream_addr,
      :upstream_status,
      :upstream_response_time,
      :upstream_response_length,
      :upstream_cache_status
    ]

    attr_reader :log_file, :current_line, :percent_read, :total_lines

    def initialize(log_file, regexp = nil)
      @log_file = File.open(log_file)
      @total_lines = File.open(log_file).readlines.size
      @percent_read = 0
      @regexp = regexp || LOG_FORMAT
    end

    def parse
      data = []
      while line_data = readline
        parsed_line = parse_line_to_object(line_data.chomp)
        data << parsed_line unless parsed_line.nil?
      end
      data
    end

    def format_time_local(dt)
      t = Time.strptime(dt, "%d/%b/%Y:%H:%M:%S %Z")
      t.strftime("%F %T")
    end

    private

    def readline
      return nil if @log_file.eof?
      @current_line = $.
      @percent_read = ((@current_line * 100) / total_lines) # $. is the current line in file reading
      return @log_file.readline
    end

    def parse_line_to_object(line)
      matches = line.match(@regexp)
      if matches then
        data = matches[1, matches.size]
        h = Hash[REQUEST_FORMAT.zip(data)]
        h[:time_local] = format_time_local(h[:time_local])
        h
      else
        STDERR.puts line
        nil
      end
    end
  end
end
