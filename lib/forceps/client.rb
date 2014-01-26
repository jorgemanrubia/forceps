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
      new_class = build_new_remote_class klass, class_name
      Forceps::Remote.const_set(class_name, new_class)
      remote_class_for(class_name).establish_connection 'remote'
    end

    def build_new_remote_class(local_class, class_name)
      needs_type_condition = (local_class.base_class != ActiveRecord::Base) && local_class.finder_needs_type_condition?
      Class.new(local_class) do
        self.table_name = local_class.table_name

        include Forceps::ActsAsCopyableModel

        # Intercep intantiation of records to make the 'type' column point to the corresponding remote class

        if Rails::VERSION::MAJOR >= 4
          def self.instantiate(record, column_types = {})
            __make_sti_column_point_to_forceps_remote_class(record)
            super
          end
        else
          def self.instantiate(record)
            __make_sti_column_point_to_forceps_remote_class(record)
            super
          end
        end

        def self.__make_sti_column_point_to_forceps_remote_class(record)
          if record[inheritance_column].present?
            record[inheritance_column] = "Forceps::Remote::#{record[inheritance_column]}"
          end
        end

        # We don't want to include STI condition automatically (the base class extends the original one)
        unless needs_type_condition
          def self.finder_needs_type_condition?
            false
          end
        end
      end
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


