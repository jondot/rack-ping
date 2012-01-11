require 'open-uri'

module Rack
  class Ping
    attr_reader :config

    def initialize(app)
      @config = {
        :version => '0',
        :check_url => nil,
        :ok_regex => nil,
        :ok_text => 'ok',
        :ok_code => 200,
        :timeout_secs => 5,
        :error_text => 'error',
        :error_code => 500
      }

      yield self if block_given?
    end

    %w[version check_url ok_regex ok_text ok_code timeout_secs error_text error_code].each do |meth|
      define_method(meth) { |value| @config[meth.to_sym] = value }
    end

    def check(&block)
      @check_block = block
    end

    def call(env)
      if @check_block
        begin
          return @check_block.call() ? ok : error("logic")
        rescue
          return error("logic: #{$!}")
        end
      end

      if @config[:ok_regex] && @config[:check_url]
        begin
          timeout(@config[:timeout_secs]) do
            text = open(@config[:check_url]).read
            return error("regex") unless text =~ @config[:ok_regex]
          end
          rescue Timeout::Error
            return error("timeout")
          rescue
            return error("url: #{$!}")
        end
      end

      return ok
    end

    def error(reason)
      [   @config[:error_code],
          NO_CACHE.merge({
            'Content-Type' => 'text/html',
            'x-app-version' => @config[:version],
            'x-ping-error'  => reason
          }),
          [@config[:error_text]]   ]
    end

    def ok
      [   @config[:ok_code],
          NO_CACHE.merge({
            'Content-Type' => 'text/html',
            'x-app-version' => @config[:version]
          }),
          [@config[:ok_text]]   ]
    end
    private
    NO_CACHE = {
      "Cache-Control" => "no-cache, no-store, max-age=0, must-revalidate",
      "Pragma" => "no-cache",
      "Expires" => "Tue, 8 Sep 1981 08:42:00 UTC"
    }
  end
end
