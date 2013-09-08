require 'helper'

#class TestGitan < Test::Unit::TestCase
#  def test_something_for_real
#    #flunk "hey buddy, you should probably rename this file and start testing for real"
#  end
#end

#
gem "test-unit"
require "test/unit"
require "gitan"
require "pp"

class TestGitan < Test::Unit::TestCase
  def test_remote_heads
    ##How should be tested?
    #pp Gitan.remote_heads("localhost", "/home/git")
  end
end
