require "org/diff/version"
require "hanami/cli"
require "org/diff/export"
require "org/diff/latex"

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

      class File < Hanami::CLI::Command
        desc "Generates the LaTeX diff of two Org files."

        argument :from, required: true, desc: "The name of the file to compare FROM."
        argument :to, required: true, desc: "The name of the file to compare TO."
        option :emacs, default: "emacsclient", desc: "Command to execute Emacs commands"
        option :latexdiff, default: "latexdiff", desc: "Command to generate the LaTeX diff. Override to use latexdiffcite, &c."
        option :pdflatex, default: "pdflatex", desc: "LaTeX implementation to run on the generate diff"


        def call(from:, to:, **options)
          emacs = options.fetch(:emacs)

          ltx_from = Org::Diff::export_org_file(from, emacs)
          ltx_to = Org::Diff::export_org_file(to, emacs)

          diff = Org::Diff::LaTeX::gen_diff(ltx_from, ltx_to, options.fetch(:latexdiff))

          Org::Diff::LaTeX::compile(diff, options.fetch(:pdflatex))
        end
      end

      register "version", Version, aliases: ["v", "-v", "--version"]
      register "file", File
    end
  end
end
