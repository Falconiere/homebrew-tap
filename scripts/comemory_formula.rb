#!/usr/bin/env ruby
# frozen_string_literal: true

# Owns the hand-maintained part of Formula/comemory.rb, which cargo-dist
# regenerates on every comemory release.
#
#   ruby scripts/comemory_formula.rb apply FILE  # add completions + lifecycle caveats (idempotent)
#   ruby scripts/comemory_formula.rb check FILE  # exit 1, listing each contract violation
#
# The lifecycle contract: comemory requires a resident sync daemon, but Homebrew
# runs formula hooks sandboxed with a temporary HOME and has no uninstall hook,
# so the formula cannot start or remove the user service itself. It must say so
# and name the supported commands instead (Falconiere/homebrew-tap#1). No
# post_install, no `service do` (the engine owns the only unit naming scheme),
# no daemon invocation outside the caveats text, and no opt-out wording.
module ComemoryFormula
  COMPLETIONS_ANCHOR = "    install_binary_aliases!\n"
  COMPLETIONS_CALL = "generate_completions_from_executable("
  COMPLETIONS_SHELLS = "shells: [:bash, :zsh, :fish, :pwsh]"
  COMPLETIONS = <<~'RUBY'.lines.map { |line| "    #{line}" }.join
    generate_completions_from_executable(
      bin/"comemory",
      "completions",
      shells: [:bash, :zsh, :fish, :pwsh],
    )
  RUBY

  CAVEATS = <<~'RUBY'
    def caveats
      <<~EOS
        comemory needs its sync daemon running, and Homebrew cannot start it:
        formula hooks run sandboxed, without access to your home directory.
        After every install, upgrade or reinstall, start and verify it with:
          #{opt_bin}/comemory sync daemon ensure
        `comemory upgrade` upgrades through Homebrew and verifies the daemon.
        Any other comemory command also restarts a missing daemon.
        Before `brew uninstall comemory`, remove the service with:
          comemory sync daemon uninstall
        This never deletes your data directory (~/.comemory by default).
      EOS
    end
  RUBY
  CAVEATS_INDENTED = CAVEATS.lines.map { |line| line.strip.empty? ? line : "  #{line}" }.join

  REQUIRED_IN_CAVEATS = [
    "sync daemon ensure",
    '#{opt_bin}/comemory',
    "comemory upgrade",
    "sync daemon uninstall",
  ].freeze
  OPT_OUT = /optional|skip|opt[ -]?out|--no-daemon|disable/i
  DAEMON_CALL = /sync["'\s,]+daemon/

  Error = Class.new(StandardError)

  module_function

  def apply(text)
    text = add_completions(text) unless text.include?(COMPLETIONS_CALL)
    text = add_caveats(text) unless caveats_range(text.lines)
    text
  end

  def add_completions(text)
    count = text.scan(COMPLETIONS_ANCHOR).length
    raise Error, "completion anchor #{COMPLETIONS_ANCHOR.strip.inspect} found #{count} times, want 1" unless count == 1

    text.sub(COMPLETIONS_ANCHOR, "#{COMPLETIONS_ANCHOR}\n#{COMPLETIONS}")
  end

  def add_caveats(text)
    lines = text.lines
    class_end = lines.rindex { |line| line.rstrip == "end" }
    raise Error, "class-closing `end` not found" unless class_end

    lines.insert(class_end, "\n", CAVEATS_INDENTED)
    lines.join
  end

  # Line indexes [start, stop] of `def caveats` .. its matching `end`, or nil.
  def caveats_range(lines)
    start = lines.index { |line| line =~ /^\s*def caveats\b/ }
    return unless start

    indent = lines[start][/^\s*/]
    stop = (start + 1...lines.length).find { |i| lines[i].chomp == "#{indent}end" }
    stop && [start, stop]
  end

  # A leading `#{` is heredoc interpolation (the caveats' opt_bin line), not a comment.
  def comment?(line)
    line.match?(/^\s*#(?!\{)/)
  end

  def problems(text)
    lines = text.lines
    code = lines.each_with_index.reject { |line, _| comment?(line) }
    found = []
    found << "missing #{COMPLETIONS_CALL.chomp('(')}" unless text.include?(COMPLETIONS_CALL)
    found << "completions must cover #{COMPLETIONS_SHELLS}" unless text.include?(COMPLETIONS_SHELLS)
    found << "post_install is forbidden (Homebrew sandboxes it with a temporary HOME)" if code.any? { |line, _| line =~ /\bpost_install/ }
    found << "service block is forbidden (the engine owns the daemon unit)" if code.any? { |line, _| line =~ /^\s*service\s+do\b/ }

    range = caveats_range(lines)
    if range
      inside = ->(i) { i.between?(*range) }
      body = code.select { |_, i| inside.call(i) }.map(&:first).join
      REQUIRED_IN_CAVEATS.each do |needle|
        found << "caveats must mention #{needle}" unless body.include?(needle)
      end
      found << "caveats offer an opt-out (#{body[OPT_OUT]})" if body =~ OPT_OUT
      outside = code.reject { |_, i| inside.call(i) }
    else
      found << "missing def caveats"
      outside = code
    end
    found << "sync daemon invoked outside caveats" if outside.any? { |line, _| line =~ DAEMON_CALL }
    found
  end

  def main(argv)
    command, path = argv
    unless %w[apply check].include?(command) && path && argv.length == 2
      warn "usage: #{$PROGRAM_NAME} apply|check FILE"
      return 2
    end
    text = File.read(path)
    if command == "apply"
      updated = apply(text)
      File.write(path, updated) unless updated == text
      return 0
    end
    found = problems(text)
    found.each { |problem| warn "contract: #{problem}" }
    found.empty? ? 0 : 1
  rescue Error, SystemCallError => e
    warn "#{command}: #{path}: #{e.message}"
    1
  end
end

exit ComemoryFormula.main(ARGV) if $PROGRAM_NAME == __FILE__
