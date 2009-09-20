require 'activesupport'
require 'fill/configure'
require 'fill/presenter'
require 'fill/procedure'

module Fill

  class << self

    def database
      db = Configure.new
      yield db
      bm = time { db.perform! }
      puts Presenter
      puts "Database filled in %.2f seconds" % bm
    end

    def time
      started_at = Time.now
      yield
      Time.now - started_at
    end

  end

end
