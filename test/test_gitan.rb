require 'helper'

#class TestGitan < Test::Unit::TestCase
#  def test_something_for_real
#    #flunk "hey buddy, you should probably rename this file and start testing for real"
#  end
#end

#
gem "test-unit"
require "test/unit"

class SampleTest < Test::Unit::TestCase
  def test_foo
    assert_equal(1,1)
    assert_equal(1,2)
  end
end
