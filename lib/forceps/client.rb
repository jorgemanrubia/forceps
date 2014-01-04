module Forceps
  class Client
    attr_reader :options

    def configure(options={})
      @options = options.merge(default_options)

      declare_remote_model_classes
      make_associations_reference_remote_classes

      Forceps.logger.debug "Classes handled by Forceps: #{model_classes.collect(&:name).inspect}"
    end

    private

    def default_options
      {}
    end

    def model_classes
      @model_classes ||= ActiveRecord::Base.descendants - [ActiveRecord::SchemaMigration]
    end

    def declare_remote_model_classes
      return if @remote_classes_defined
      model_classes.each { |remote_class| declare_remote_model_class(remote_class) }
      @remote_classes_defined = true
    end

    def declare_remote_model_class(klass)
      class_name = klass.name

      new_class = Class.new(klass) do
        table_name = class_name.tableize
      end

      Forceps::Remote.const_set(class_name, new_class)
      remote_class_for(class_name).establish_connection 'remote'
    end

    def remote_class_for(class_name)
      Forceps::Remote::const_get(class_name)
    end

    def make_associations_reference_remote_classes
      model_classes.each do |model_class|
        make_associations_reference_remote_classes_for(model_class)
      end
    end

    def make_associations_reference_remote_classes_for(model_class)
      model_class.reflect_on_all_associations.each do |association|
        next if association.klass.name =~ /Forceps::Remote/
        reference_remote_class(model_class, association)
      end
    end

    def reference_remote_class(model_class, association)
      related_remote_class = remote_class_for(association.klass.name)
      remote_model_class = remote_class_for(model_class.name)

      cloned_association = association.dup
      cloned_association.instance_variable_set("@klass", related_remote_class)

      cloned_reflections = remote_model_class.reflections.dup
      cloned_reflections[cloned_association.name.to_sym] = cloned_association
      remote_model_class.reflections = cloned_reflections
    end
  end
end


