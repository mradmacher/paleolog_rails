require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def test_if_sham_is_valid
    assert User.sham!( :build ).valid?
  end
end
