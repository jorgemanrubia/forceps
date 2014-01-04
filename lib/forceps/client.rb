module Forceps
  class Client
    attr_reader :options

    def configure(options={})
      @options = options.merge(default_options)

      define_remote_classes
      make_associations_reference_remote_classes
    end

    private

    def default_options
      {}
    end

    def remote_classes
      @remote_classes ||= ActiveRecord::Base.descendants - [ActiveRecord::SchemaMigration]
    end

    def define_remote_classes
      return if @remote_classes_defined
      remote_classes.each{|remote_class| define_remote_class(remote_class)}
      @remote_classes_defined = true
    end

    def define_remote_class(klass)
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
      remote_classes.each do |remote_class|
        make_associations_reference_remote_classes_for(remote_class)
      end
    end

    def make_associations_reference_remote_classes_for(remote_class)
      remote_class.reflect_on_all_associations.each do |association|
        next if association.klass.name =~ /Forceps::Remote/
        reference_remote_classes(association)
      end
    end

    def reference_remote_classes(association)
      related_remote_class = remote_class_for(association.klass.name)
      association.instance_variable_set("@klass", related_remote_class)
    end
  end
end


