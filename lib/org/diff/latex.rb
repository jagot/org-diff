require "shell"

module Org
  module Diff
    module LaTeX
      def self.gen_diff(from, to, latexdiff)
        diff = "diff-#{File.basename(from, ".*")}-#{File.basename(to, ".*")}.tex"
        puts "- Generating diff between #{from} and #{to} using #{latexdiff} -> #{diff}"
        cmd = "#{latexdiff} #{from} #{to}"
        puts "$ #{cmd}"
        sh = Shell.new
        sh.system(cmd) > diff
        diff
      end

      def self.compile(filename, pdflatex, output: nil)
        puts "- Compiling #{filename} using #{pdflatex}"
        output = "#{File.basename(filename, ".*")}.pdf" if output.nil?
        cmd = "latexmk -pdflatex=\"#{pdflatex}\" -jobname=#{File.basename(output, ".*")} #{filename}"
        puts "$ #{cmd}"
        `#{cmd}`
        $?.exitstatus == 0 or raise "Failed to compile #{filename}"
        output
      end
    end
  end
end
