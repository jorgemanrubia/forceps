module Forceps
  class Client
    attr_reader :options

    def configure(options={})
      @options = options.merge(default_options)

      define_remote_classes
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
      Forceps::Remote::const_get(class_name).establish_connection 'remote'
    end
  end
end


