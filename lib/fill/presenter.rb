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

    def add(data)
      presented.push(data) if data && !presented.include?(data)
    end

    def hirb?
      require 'hirb'
      true
    rescue LoadError
      false
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
        row.map { |key, value| "#{key}: #{value}" }.join(" - ")
      end
    end

  end

end
