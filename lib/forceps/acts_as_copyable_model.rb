module Forceps
  module ActsAsCopyableModel
    extend ActiveSupport::Concern

    def copy_to_local
      # 'self.dup.becomes(Invoice)' won't work due to managing different connections.
      # Let's clone attributes manually (this will work for Rails 4 for now, we should whitelist all attributes
      # for Rails 3)
      Invoice.record_timestamps = false
      cloned_record = Invoice.new(self.attributes)
      cloned_record.save!
      Invoice.record_timestamps = true
    end
  end
end

ActiveRecord::Base.send :include, Forceps::ActsAsCopyableModel