require 'test_helper'

class ExcludeAssociatedRecordsTest < ActiveSupport::TestCase
  def setup
    Forceps.configure exclude: {Tag => [:products]}
  end

  test "should exclude the associations set in the 'exclude' option" do

  end
end