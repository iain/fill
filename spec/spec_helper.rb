require File.dirname(__FILE__) + '/../lib/fill'

require 'spec'
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
    def delete_all; 1; end
    def count; 2; end
    def human_name; self.inspect; end
    def create!; end
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

class User < ActiveRecordMimic; end

class Project < ActiveRecordMimic; end

class Membership < ActiveRecordMimic; end
