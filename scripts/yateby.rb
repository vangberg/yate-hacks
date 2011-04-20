require "uuid"

def uuid
  @uuid ||= UUID.new
  @uuid.generate
end

def now
  Time.now.to_i
end

def transmit msg
  $stdout.print(msg.to_s)
  $stdout.flush
end

def msg *args
  $stdout.print "%%>#{args.join(":")}\n"
  $stdout.flush
end

def reply *args
  $stdout.print "%%<#{args.join(":")}\n"
  $stdout.flush
end

def log message
  $stderr.puts "<<#{$0}>> #{message}"
  $stderr.flush
end

def watch name
  msg "watch", name
end

def install *args
  msg "install", *args
end

def next_message
  line = $stdin.gets
  Yateby::Message.parse(line)
end

module Yateby
  class Message
    def self.parse raw
      case raw[0..2]
      when "%%>" then
        Request.parse(raw)
      when "%%<" then
        Response.parse(raw)
      end
    end

    def self.parse_params arr
      hash = {}
      arr.each {|kv|
        key, value = kv.split("=")
        hash[key] = value
      }
      hash
    end

    attr_accessor :id
    attr_accessor :name
    attr_accessor :retvalue
    attr_accessor :params

    def initialize
      @params = {}
      @id = UUID.new.generate
    end

    def [] key
      params[key]
    end

    def []= key, value
      params[key] = value
    end

    def params_string
      params.map {|key, value| "#{key}=#{value}"}.join(":")
    end
  end

  class Request < Message
    def self.parse raw
      arr = raw.split(":")
      msg = new
      msg.id, msg.time, msg.name, msg.retvalue = arr.slice!(1..4)
      msg.params = parse_params(arr)
      msg
    end

    attr_accessor :time

    def to_s
      "%%>message:#{id}:#{time}:#{name}:#{retvalue}:#{params_string}\n"
    end
  end

  class Response < Message
    def self.parse raw
      arr = raw.split(":")
      msg = new
      msg.id, msg.processed, msg.name, msg.retvalue = arr.slice!(1..4)
      msg.params = parse_params(arr)
      msg
    end

    attr_accessor :processed

    def to_s
      "%%<message:#{id}:#{processed}:#{name}:#{retvalue}:#{params_string}\n"
    end
  end
end
