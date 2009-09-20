module Fill

  class Configure

    def produce(*models, &block)
      options = models.extract_options!
      needs = options.delete(:needs) || []
      register models, Procedure.new(models, options, &block)
      dependent models, needs
    end

    def fill(model, field, *values)
      options = values.extract_options!
      self.produce model, options do
        values.each do |value|
          model.to_s.singularize.camelize.constantize.create!(field => value)
        end
      end
    end

    def invoke(task, *models)
      self.produce *models do
        Rake::Task[task].invoke
      end
    end

    def environment(env, which, options = {})

    end

    def perform!
      registered.each_key { |model| perform(model) }
    end

    private

    def results
      results = registered.values.uniq.compact.map { |data| data.to_hash }
    end

    def perform(model)
      raise "No fill data provided for #{model}" unless registered.has_key? model
      dependencies[model].each { |dep| perform(dep) } if dependencies.has_key? model
      registered[model].perform!
    end

    def register(models, data)
      models.each do |model|
        registered.update model => data
      end
    end

    def dependent(models, dependent)
      models.each do |model|
        dependencies.update model => [dependent].flatten
      end
    end

    def registered
      @registered ||= {}
    end

    def dependencies
      @dependencies ||= {}
    end

  end

end
