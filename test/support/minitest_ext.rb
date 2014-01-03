module Minitest
  module Assertions
    # Compares the equality at the attribute level
    def assert_identical expected, actual, msg = nil
      ignored_attributes = %w(id)
      assert_equal expected.class, actual.class
      assert_equal expected.attributes.except(*ignored_attributes),
                   actual.attributes.except(*ignored_attributes)
    end
  end
end

