# Extension for Net::BufferedIO
module Slowproxy
  module SlowBufferedIO
    BUFSIZE = Net::BufferedIO::BUFSIZE # 1024 * 16

    def self.bps=(bps)
      @bps = bps
      @wait = nil
    end

    def self.bps
      @bps ||= 128 * 1024
    end

    def self.logger=(logger)
      @logger = logger
    end

    def self.logger
      @logger
    end

    def self.wait
      @wait ||= 1 / ((bps / 8.0) / BUFSIZE)
    end

    def rbuf_fill
      logger.info "wait for read (#{SlowBufferedIO.wait}s)" if logger
      sleep SlowBufferedIO.wait
      super
    end

    def write0(str)
      if str.bytesize > BUFSIZE
        logger.info "wait for write (#{str.bytesize * 8.0 / SlowBufferedIO.bps}s)" if logger
        len = 0
        str.each_byte.each_slice(BUFSIZE) do |bytes|
          len += super(bytes.pack("C*"))
          sleep SlowBufferedIO.wait
        end
        len
      else
        super
      end
    end

    def logger
      SlowBufferedIO.logger
    end
  end
end

