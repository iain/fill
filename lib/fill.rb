require 'activesupport'
require File.dirname(__FILE__) + '/fill/configure'
require File.dirname(__FILE__) + '/fill/presenter'
require File.dirname(__FILE__) + '/fill/procedure'

module Fill

  class << self


    attr_writer :out
    def out
      @out ||= STDOUT
    end

    def database
      db = Configure.new
      yield db
      perform!(db)
    end

    def perform!(configuration)
      bm = time { configuration.perform! }
      out.puts Presenter
      out.puts "Database filled in %.2f seconds" % bm
      Presenter.clear!
    end

    def time
      started_at = Time.now
      yield
      Time.now - started_at
    end

  end

end
