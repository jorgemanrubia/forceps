module Forceps
  class Client
    attr_reader :options

    def configure(options={})
      @options = options.merge(default_options)

      declare_remote_model_classes
      make_associations_reference_remote_classes

      logger.debug "Classes handled by Forceps: #{model_classes.collect(&:name).inspect}"
    end

    private

    def logger
      Forceps.logger
    end

    def default_options
      {}
    end

    def model_classes
      @model_classes ||= ActiveRecord::Base.descendants - model_classes_to_exclude
    end

    def model_classes_to_exclude
      if Rails::VERSION::MAJOR >= 4
        [ActiveRecord::SchemaMigration]
      else
        []
      end
    end

    def declare_remote_model_classes
      return if @remote_classes_defined
      model_classes.each { |remote_class| declare_remote_model_class(remote_class) }
      @remote_classes_defined = true
    end

    def declare_remote_model_class(klass)
      class_name = remote_class_name_for(klass.name)

      needs_type_condition = (klass.base_class != ActiveRecord::Base) && klass.finder_needs_type_condition?
      new_class = Class.new(klass) do
        table_name = class_name.tableize

        # We don't want to include STI condition automatically (the base class extends the original one)
        unless needs_type_condition
          def self.finder_needs_type_condition?
            false
          end
        end
      end

      Forceps::Remote.const_set(class_name, new_class)
      remote_class_for(class_name).establish_connection 'remote'
    end

    def remote_class_name_for(local_class_name)
      local_class_name.gsub('::', '_')
    end

    def remote_class_for(class_name)
      Forceps::Remote::const_get(remote_class_name_for(class_name))
    end

    def make_associations_reference_remote_classes
      model_classes.each do |model_class|
        make_associations_reference_remote_classes_for(model_class)
      end
    end

    def make_associations_reference_remote_classes_for(model_class)
      model_class.reflect_on_all_associations.each do |association|
        next if association.class_name =~ /Forceps::Remote/ rescue next
        reference_remote_class(model_class, association)
      end
    end

    def reference_remote_class(model_class, association)
      remote_model_class = remote_class_for(model_class.name)

      if association.options[:polymorphic]
        reference_remote_class_in_polymorfic_association(association, remote_model_class)
      else
        reference_remote_class_in_normal_association(association, remote_model_class)
      end
    end

    def reference_remote_class_in_polymorfic_association(association, remote_model_class)
      # todo: test
      foreign_type_attribute_name = association.foreign_type

      remote_model_class.send(:define_method, association.foreign_type) do
        "Forceps::Remote::#{super()}"
      end

      remote_model_class.send(:define_method, "[]") do |attribute_name|
        if (attribute_name.to_s==foreign_type_attribute_name)
          "Forceps::Remote::#{super(attribute_name)}"
        else
          super(attribute_name)
        end
      end
    end

    def reference_remote_class_in_normal_association(association, remote_model_class)
      related_remote_class = remote_class_for(association.klass.name)

      cloned_association = association.dup
      cloned_association.instance_variable_set("@klass", related_remote_class)

      cloned_reflections = remote_model_class.reflections.dup
      cloned_reflections[cloned_association.name.to_sym] = cloned_association
      remote_model_class.reflections = cloned_reflections
    end
  end
end


