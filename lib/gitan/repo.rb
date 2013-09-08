#
class Gitan::Repo

  def self.show_abbreviation(io = $stdout)
    io.puts "==== B: multiple branches, S: to be staged, C: to be commited, P: to be pushed, L: to be pulled."
  end

  def initialize(path, remote_head = false)
    @path = path
    @remote_head = remote_head
  end

  #Return short status as String. E.g,
  #"BSCP path",
  #"  C  path"
  # B: contain multiple Branches
  # S: to be staged
  # C: to be commited
  # P: to be pushed
  def short_status
    l = " "
    l = "L" if @remote_head && to_be_pulled?

    b = " "
    b = "B" if multiple_branch?

    s = " "
    s = "S" if to_be_staged?

    c = " "
    c = "C" if to_be_commited?

    p = " "
    p = "P" if to_be_pushed?

    return (l + b + s + c + p  + " " + File.basename(@path))
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
    result = true

    remote_lines = command_output_lines("git rev-parse --remotes")
    result = false if remote_lines.include?(head)

    fetch_head = command_output_lines("git rev-parse FETCH_HEAD")[0]
    result = false if head == fetch_head

    return result
  end

  def head
    command_output_lines("git rev-parse HEAD")[0]
  end

  #Return true if the working tree has un-pulled changes on remote.
  def to_be_pulled?
    lines = command_output_lines('git log --pretty=format:"%H"')
    return ! lines.include?(@remote_head)
  end

  private

  def command_output_lines(str)
    Dir.chdir @path
    `#{str}`.split("\n")
  end

end
