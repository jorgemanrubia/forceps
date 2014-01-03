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
      def copy(record)
        # 'self.dup.becomes(Invoice)' won't work because of different  AR connections.
        # todo: prepare for rails 3 and attribute protection
        record.class.base_class.create!(record.attributes.except('id'))
      end
    end
  end
end

ActiveRecord::Base.send :include, Forceps::ActsAsCopyableModel