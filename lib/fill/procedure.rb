module Fill

  class Procedure

    attr_accessor :block

    def initialize(models, options = {}, &block)
      @block   = block
      @options = { :delete => true }.merge(options)
      @models  = models
    end

    def perform!
      @performed ||= perform
    end

    def to_hash
      { "Models" => human_models, "Before" => @before.join(', '), "After" => @after.join(', '), "Time" => @time }
    end

    def human_models
      @options[:name] ||
      models.map { |model| model.respond_to?(:human_name) ? model.human_name : model.to_s }.join(', ')
    end

    def delete_all
      models.each { |model| model.delete_all } if @options[:delete]
    end

    def models
      @models.map { |model| model.to_s.singularize.camelize.constantize }
    end

    def count
      models.map { |model| model.count }
    end

    def perform
      @before = count
      @time   = Fill.time { self.delete_all; block.call }
      @after  = count
      Presenter.present self
      true
    end

  end

end
