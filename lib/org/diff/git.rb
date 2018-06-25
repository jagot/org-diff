require "tmpdir"

module Org
  module Diff
    module Git
      def self.checkout(revision)
        Dir.mktmpdir do |dir|
          cmd = "git clone --recurse-submodules . #{dir}"
          puts "$ #{cmd}"
          `#{cmd}`
          $?.exitstatus == 0 or raise "Failed to clone repo"
          FileUtils.chdir(dir) do
            cmd = "git checkout #{revision}"
            puts "$ #{cmd}"
            `#{cmd}`
            $?.exitstatus == 0 or raise "Failed to checkout #{revision}"
          end
          yield dir
        end
      end
    end
  end
end
