module Forceps
  module ActsAsCopyableModel
    extend ActiveSupport::Concern

    def copy_to_local
      without_record_timestamps do
        deep_copier.copy(self)
      end
    end

    private

    def deep_copier
      @deep_copier ||= DeepCopier.new
    end

    def without_record_timestamps
      self.class.base_class.record_timestamps = false
      yield
    ensure
      self.class.base_class.record_timestamps = true
    end

    class DeepCopier
      def copy(remote_object)
        # 'self.dup.becomes(Invoice)' won't work because of different  AR connections.
        # todo: prepare for rails 3 and attribute protection
        copied_object = remote_object.class.base_class.create!(remote_object.attributes.except('id'))

        remote_object.class.reflect_on_all_associations(:has_many).collect(&:name).each do |association_name|
          remote_object.send(association_name).find_each do |remote_associated_object|
            remote_object.send(association_name) << copy(remote_associated_object)
          end
        end

        copied_object
      end
    end
  end
end

ActiveRecord::Base.send :include, Forceps::ActsAsCopyableModel