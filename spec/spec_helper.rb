require File.dirname(__FILE__) + '/../lib/fill'

Spec::Runner.configure do |config|
  config.mock_with :rr
end

def produce!(*args)
  args = [:projects] if args.empty?
  Fill.database do |db|
    db.produce *args do
      yield if block_given?
    end
  end
end

class ActiveRecordMimic
  class << self
    attr_reader :delete_all, :count, :create, :human_name
  end
end

class Output
  class << self
    attr_accessor :output
    def puts(string)
      @output ||= []
      @output << string.to_s
    end
  end
end
Fill.out = Output

class User       < ActiveRecordMimic; end
class Project    < ActiveRecordMimic; end
class Membership < ActiveRecordMimic; end
