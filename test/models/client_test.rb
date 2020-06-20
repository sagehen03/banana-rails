require 'test_helper'

class ClientTest < ActiveSupport::TestCase
  test "Client should not save unless validations pass" do
    client = Client.create {}
    assert_not_nil client.errors.messages
  end
end
