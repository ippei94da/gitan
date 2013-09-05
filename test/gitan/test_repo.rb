gem "test-unit"
require "test/unit"
require "gitan"


#class GritRepoDummy
#  attr_accessor :status
#  def initialize(status)
#    @status = status
#  end
#end
#
#class GritRepoStatusDummy
#  attr_accessor :changed
#  attr_accessor :added
#  attr_accessor :deleted
#  attr_accessor :untracked
#  attr_accessor :pretty
#  def initialize
#    @changed
#    @added
#    @deleted
#    @untracked
#    @pretty
#  end
#end

class Gitan::Repo
  public :command_output_lines
  attr_accessor :outputs
  #public :staged_lines
  #public :unstaged_lines

  def set_outputs(outputs)
    @outputs = outputs
  end

  def command_output_lines(str)
    return @outputs[str]
  end
end

class TestRepo < Test::Unit::TestCase
  def setup
    outputs = {
      "git branch" => ["* master"],
      "git status -s" => [],
      "git rev-parse HEAD" => ["b4a9cab36b51cc8ca9b9a67d4b7c82abf6f02df4"],
      "git rev-parse --remotes" => [
        "b4a9cab36b51cc8ca9b9a67d4b7c82abf6f02df4",
        "d37ebd5948c87c142cf52572c44f032896879ec9",
      ],
    }
    @r00 = Gitan::Repo.new("r00")
    @r00.set_outputs(outputs)

    outputs = {
      "git branch" => ["* master", "  tmp"],
      "git status -s" => [
        " M Gemfile",
        "AM bin/gitanstatus",
        "?? test/gitan/",
      ],
      "git rev-parse HEAD" => ["b4a9cab36b51cc8ca9b9a67d4b7c82abf6f02df4"],
      "git rev-parse --remotes" => [
        "6671b434a3ed6414cab0c676a90c575bbb03d9da",
        "d37ebd5948c87c142cf52572c44f032896879ec9",
      ],
    }
    @r01 = Gitan::Repo.new("r01")
    @r01.set_outputs(outputs)

    outputs = {
      "git branch" => ["* master", "  tmp"],
      "git status -s" => [
        "?? test/gitan/",
      ],
      "git rev-parse HEAD" => ["b4a9cab36b51cc8ca9b9a67d4b7c82abf6f02df4"],
      "git rev-parse --remotes" => [
        "6671b434a3ed6414cab0c676a90c575bbb03d9da",
        "b4a9cab36b51cc8ca9b9a67d4b7c82abf6f02df4",
      ],
    }
    @r02 = Gitan::Repo.new("r02")
    @r02.set_outputs(outputs)

    outputs = {
      "git branch" => ["* master"],
      "git status -s" => [],
      "git rev-parse HEAD" => ["b4a9cab36b51cc8ca9b9a67d4b7c82abf6f02df4"],
      "git rev-parse --remotes" => [
        "b4a9cab36b51cc8ca9b9a67d4b7c82abf6f02df4",
      ],
    }
    @r03 = Gitan::Repo.new("r00")
    @r03.set_outputs(outputs)

  end

  def test_to_be_staged?
    assert_equal(false, @r00.to_be_staged?)
    assert_equal(true , @r01.to_be_staged?)

    @r00.outputs["git status -s"] = [
        "?? test/gitan/",
    ]
    assert_equal(true , @r00.to_be_staged?)

    @r00.outputs["git status -s"] = [
      " M Gemfile",
      "AM bin/gitanstatus",
    ]
    assert_equal(false, @r00.to_be_staged?)
  end

  def test_to_be_commited?
    assert_equal(false, @r00.to_be_commited?)
    assert_equal(true , @r01.to_be_commited?)

    @r00.outputs["git status -s"] = [
        "?? test/gitan/",
    ]
    assert_equal(false, @r00.to_be_commited?)

    @r00.outputs["git status -s"] = [
      " M Gemfile",
      "AM bin/gitanstatus",
    ]
    assert_equal(true, @r00.to_be_commited?)
  end

  def test_command_output_lines
    assert_equal(
      [
        "b4a9cab36b51cc8ca9b9a67d4b7c82abf6f02df4",
        "d37ebd5948c87c142cf52572c44f032896879ec9",
      ],
      @r00.command_output_lines("git rev-parse --remotes")
    )

    assert_equal(
      [
        "6671b434a3ed6414cab0c676a90c575bbb03d9da",
        "d37ebd5948c87c142cf52572c44f032896879ec9",
      ],
      @r01.command_output_lines("git rev-parse --remotes")
    )
  end

  def test_to_be_pushed?
    assert_equal(false, @r00.to_be_pushed?)
    assert_equal(true , @r01.to_be_pushed?)
    assert_equal(false , @r03.to_be_pushed?)
  end

  def test_multiple_branch?
    assert_equal(false, @r00.multiple_branch?)
    assert_equal(true , @r01.multiple_branch?)
    assert_equal(true , @r02.multiple_branch?)
  end

  def test_short_status
    assert_equal("     r00", @r00.short_status)
    assert_equal("BSCP r01", @r01.short_status)
    assert_equal("BS   r02", @r02.short_status)
  end

end