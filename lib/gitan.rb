module Gitan; end

require "pp"
require "yaml"
#require "grit"
require "gitan/repo.rb"

module Gitan

  #Return heads in remote host.
  def self.remote_heads(server, path)
    results = {}
    YAML.load(`ssh #{server} gitanheads #{path}`).each do |repo_path, head|
      repo_name = File.basename(repo_path).sub(/\.git$/, "")
      results[repo_name] = head
    end
    return results
  end
end
