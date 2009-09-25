module Fill

  class Procedure

    attr_accessor :block, :options

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
      @human_models ||= (options[:name] || humanize_models)
    end

    def humanize_models
      models.map { |model| i18n_name(model) }.join(', ')
    end

    def i18n_name(model)
      model.respond_to?(:human_name) ? model.human_name : model.to_s
    end

    def delete_all
      models.map { |model| model.delete_all }
    end

    def models
      @models.map { |model| model.to_s.singularize.camelize.constantize }
    end

    def count
      models.map { |model| model.count }
    end

    def perform
      @before = options[:delete] ? delete_all : count
      @time   = Fill.time { block.call }
      @after  = count
      Presenter.present self
      true
    end

  end

end
