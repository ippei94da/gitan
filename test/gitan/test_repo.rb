gem "test-unit"
require "test/unit"
require "gitan"

#class GritRepoDummy #  attr_accessor :status #  def initialize(status) #    @status = status #  end #end #
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
      "git rev-parse HEAD" => ["aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"],
      "git rev-parse FETCH_HEAD" => ["aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"],
      "git rev-parse --remotes" => [
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
      ],
    }
    @r00 = Gitan::Repo.new("/home/git/r00")
    @r00.set_outputs(outputs)

    outputs = {
      "git branch" => ["* master", "  tmp"],
      "git status -s" => [
        " M Gemfile",
        "AM bin/gitanstatus",
        "?? test/gitan/",
      ],
      "git rev-parse HEAD" => ["aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"],
      "git rev-parse FETCH_HEAD" => ["dddddddddddddddddddddddddddddddddddddddd"],
      "git rev-parse --remotes" => [
        "cccccccccccccccccccccccccccccccccccccccc",
        "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
      ],
    }
    @r01 = Gitan::Repo.new("/home/git/r01")
    @r01.set_outputs(outputs)

    outputs = {
      "git branch" => ["* master", "  tmp"],
      "git status -s" => [
        "?? test/gitan/",
      ],
      "git rev-parse HEAD" => ["aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"],
      "git rev-parse FETCH_HEAD" => ["aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"],
      "git rev-parse --remotes" => [
        "cccccccccccccccccccccccccccccccccccccccc",
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
      ],
    }
    @r02 = Gitan::Repo.new("/home/git/r02")
    @r02.set_outputs(outputs)

    outputs = {
      "git branch" => ["* master"],
      "git status -s" => [],
      "git rev-parse HEAD" => ["aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"],
      "git rev-parse FETCH_HEAD" => ["aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"],
      "git rev-parse --remotes" => [
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
      ],
    }
    @r03 = Gitan::Repo.new("/home/git/r00")
    @r03.set_outputs(outputs)

    outputs = {
      "git branch" => ["* master"],
      "git status -s" => [],
      "git rev-parse HEAD" => ["aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"],
      "git rev-parse FETCH_HEAD" => ["aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"],
      "git rev-parse --remotes" => [
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
      ],
      'git log --pretty=format:"%H"' => [
        'eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee',
        'ffffffffffffffffffffffffffffffffffffffff',
        '0000000000000000000000000000000000000000',
      ]
    }
    @r04 = Gitan::Repo.new("/home/git/r04","aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
    @r04.set_outputs(outputs)

    @r05 = Gitan::Repo.new("/home/git/r05","eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee")
    @r05.set_outputs(outputs)

    outputs = {
      "git branch" => ["* master", "  tmp"],
      "git status -s" => [
        " M Gemfile",
        "AM bin/gitanstatus",
        "?? test/gitan/",
      ],
      "git rev-parse HEAD" => ["aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"],
      "git rev-parse FETCH_HEAD" => ["aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"],
      "git rev-parse --remotes" => [
        "cccccccccccccccccccccccccccccccccccccccc",
        "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
      ],
    }
    @r06 = Gitan::Repo.new("/home/git/r01")
    @r06.set_outputs(outputs)

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
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
      ],
      @r00.command_output_lines("git rev-parse --remotes")
    )

    assert_equal(
      [
        "cccccccccccccccccccccccccccccccccccccccc",
        "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
      ],
      @r01.command_output_lines("git rev-parse --remotes")
    )
  end

  def test_to_be_pushed?
    assert_equal(false, @r00.to_be_pushed?)
    assert_equal(true , @r01.to_be_pushed?)
    assert_equal(false , @r03.to_be_pushed?)
    assert_equal(false , @r06.to_be_pushed?)
  end

  def test_multiple_branch?
    assert_equal(false, @r00.multiple_branch?)
    assert_equal(true , @r01.multiple_branch?)
    assert_equal(true , @r02.multiple_branch?)
  end

  def test_short_status
    assert_equal("      r00", @r00.short_status)
    assert_equal(" BSCP r01", @r01.short_status)
    assert_equal(" BS   r02", @r02.short_status)
    assert_equal("L     r04", @r04.short_status)
    assert_equal("      r05", @r05.short_status)
  end

  def test_head
    assert_equal("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
                 @r00.head)
  end

  def test_to_be_pulled?
    assert_equal(true , @r04.to_be_pulled?)
    assert_equal(false, @r05.to_be_pulled?)
  end


end
