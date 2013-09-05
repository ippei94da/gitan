#
class Gitan::Repo

  def self.show_abbreviation(io = $stdout)
    io.puts "==== B: multiple branches, S: to be staged, C: to be commited, P: to be pushed."
  end

  def initialize(path)
    @path = path
  end

  #Return short status as String. E.g,
  #"BSCP path",
  #"  C  path"
  # B: contain multiple Branches
  # S: to be staged
  # C: to be commited
  # P: to be pushed
  def short_status
    b = " "
    b = "B" if multiple_branch?

    s = " "
    s = "S" if to_be_staged?

    c = " "
    c = "C" if to_be_commited?

    p = " "
    p = "P" if to_be_pushed?

    return (b + s + c + p + " " + @path)
  end

  def multiple_branch?
    lines = command_output_lines("git branch")
    return lines.size > 1
  end

  #Return true if working tree has untracked changes.
  def to_be_staged?
    lines = command_output_lines("git status -s")
    return lines.select {|line| line =~ /^\?\?/} != []
  end

  #Return true if working tree has changes on stage index.
  def to_be_commited?
    lines = command_output_lines("git status -s")
    return lines.select {|line| line =~ /^[^\?]/} != []
  end

  #Return true if working tree has change which is commited but not pushed.
  def to_be_pushed?
    remote_lines = command_output_lines("git rev-parse --remotes")
    return (! remote_lines.include?(head))
  end

  def head
    command_output_lines("git rev-parse HEAD")[0]
  end

  private

  #def short_status_lines
  #  `git status -s`.split("\n")
  #end

  def command_output_lines(str)
    Dir.chdir @path
    `#{str}`.split("\n")
  end

end
