module Forceps
  module ActsAsCopyableModel
    extend ActiveSupport::Concern

    def copy_to_local
      # 'self.dup.becomes(Invoice)' won't work because of different  AR connections.
      # todo: prepare for rails 3 and attribute protection
      without_record_timestamps do
        cloned_record = self.class.base_class.new(self.attributes.except('id'))
        cloned_record.save!
      end
    end

    private

    def without_record_timestamps
      self.class.base_class.record_timestamps = false
      yield
    ensure
      self.class.base_class.record_timestamps = true
    end
  end
end

ActiveRecord::Base.send :include, Forceps::ActsAsCopyableModel