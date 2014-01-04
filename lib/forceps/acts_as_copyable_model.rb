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
        copy_associated_objects(copied_object, remote_object)
        copied_object
      end

      def copy_associated_objects(local_object, remote_object)
        copy_objects_associated_by_association_kind(local_object, remote_object, :has_many)
        copy_objects_associated_by_association_kind(local_object, remote_object, :has_one)
      end

      def copy_objects_associated_by_association_kind(local_object, remote_object, association_kind)
        remote_object.class.reflect_on_all_associations(association_kind).collect(&:name).each do |association_name|
          send "copy_associated_objects_in_#{association_kind}", local_object, remote_object, association_name
        end
      end

      def copy_associated_objects_in_has_many(local_object, remote_object, association_name)
        remote_object.send(association_name).find_each do |remote_associated_object|
          local_object.send(association_name) << copy(remote_associated_object)
        end
      end

      def copy_associated_objects_in_has_one(local_object, remote_object, association_name)
        remote_associated_object = remote_object.send(association_name)
        local_object.send "#{association_name}=", remote_associated_object && copy(remote_associated_object)
        local_object.save!
      end
    end
  end
end

ActiveRecord::Base.send :include, Forceps::ActsAsCopyableModel