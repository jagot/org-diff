require "org/diff/version"
require "hanami/cli"
require "org/diff/export"
require "org/diff/latex"
require "org/diff/git"
require "fileutils"

module Org
  module Diff
    module Commands
      extend Hanami::CLI::Registry

      class Version < Hanami::CLI::Command
        desc "Print version"

        def call(*)
          puts Org::Diff::VERSION
        end
      end

      COMMON_DIFF_OPTIONS = {:emacs => {:default => "emacsclient", :desc => "Command to execute Emacs commands"},
                             :latexdiff => {:default => "latexdiff", :desc => "Command to generate the LaTeX diff. Override to use latexdiffcite, &c."},
                             :pdflatex => {:default => "pdflatex", :desc => "LaTeX implementation to run on the generate diff"},
                             :output => {:default => nil, :desc => "Override output filename"}}

      class File < Hanami::CLI::Command
        desc "Generates the LaTeX diff of two Org files."

        argument :from, required: true, desc: "The name of the file to compare FROM."
        argument :to, required: true, desc: "The name of the file to compare TO."

        COMMON_DIFF_OPTIONS.each do |k,v|
          option k, **v
        end

        def call(from:, to:, **options)
          emacs = options.fetch(:emacs)

          ltx_from = Org::Diff::export_org_file(from, emacs)
          ltx_to = Org::Diff::export_org_file(to, emacs)

          diff = Org::Diff::LaTeX::gen_diff(ltx_from, ltx_to, options.fetch(:latexdiff))

          Org::Diff::LaTeX::compile(diff, options.fetch(:pdflatex),
                                    output: options.fetch(:output))
        end
      end

      class Git < Hanami::CLI::Command
        desc "Generates the LaTeX diff of an Org file from different revisions"

        argument :file, required: true, desc: "Name of Org file"

        argument :old, required: true, desc: "Old revision of Org file."
        argument :new, desc: "New revision of Org file."

        COMMON_DIFF_OPTIONS.each do |k,v|
          option k, **v
        end

        def call(file:, old:, new: "HEAD", **options)
          emacs = options.fetch(:emacs)

          start_dir = FileUtils.pwd()

          Org::Diff::Git::checkout(old) do |old_dir|
            ltx_from = ""
            FileUtils.chdir(old_dir) do
              ltx_from = Org::Diff::export_org_file(file, emacs)
            end
            Org::Diff::Git::checkout(new) do |new_dir|
              FileUtils.chdir(new_dir) do
                ltx_to = Org::Diff::export_org_file(file, emacs)

                diff = Org::Diff::LaTeX::gen_diff(ltx_from, ltx_to, options.fetch(:latexdiff))

                pdf_diff = Org::Diff::LaTeX::compile(diff, options.fetch(:pdflatex),
                                                     output: options.fetch(:output, "diff-#{::File.basename(file, ".*")}-#{old}-#{new}.pdf"))
                FileUtils.cp(pdf_diff, start_dir)
              end
            end
          end
        end
      end

      register "version", Version, aliases: ["v", "-v", "--version"]
      register "file", File, aliases: ["f"]
      register "git", Git, aliases: ["g"]
    end
  end
end
