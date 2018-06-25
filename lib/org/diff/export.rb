module Org
  module Diff
    def self.export_org_file(filename, emacs)
      output = "#{File.dirname(filename)}/#{File.basename(filename, ".*")}.tex"
      puts "- Exporting #{filename} to LaTeX using #{emacs} -> #{output}"
      cmd = "#{emacs} -e \"(progn (find-file \\\"#{filename}\\\") (org-latex-export-to-latex))\""
      puts "$ #{cmd}"
      `#{cmd}`
      $?.exitstatus == 0 or raise "Failed to export #{filename} to #{output}"
      output
    end
  end
end
