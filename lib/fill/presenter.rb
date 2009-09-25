module Fill

  class Presenter

    def self.present(data)
      presenter.add(data)
    end

    def self.presenter
      @presenter ||= new
    end

    def self.to_s
      presenter.to_s
    end

    def self.hirb?
      require 'hirb'
      true
    rescue LoadError
      false
    end

    def self.clear!
      @presenter = nil
    end

    def add(data)
      presented.push(data) if data && !presented.include?(data)
    end

    def hirb?
      self.class.hirb?
    end

    def presented
      @presented ||= []
    end

    def presentable
      presented.map(&:to_hash)
    end

    def present_with_hirb
      Hirb::Helpers::Table.render(presentable, :description => false)
    end

    def to_s
      hirb? ? present_with_hirb : present_hash.join("\n")
    end

    def present_hash
      presentable.map do |row|
        format_row(row).join(" - ")
      end
    end

    def format_row(row)
      row.map do |key, value|
        value = "%.2f" % value if key == "Time"
        "#{key}: #{value}"
      end
    end

  end

end
