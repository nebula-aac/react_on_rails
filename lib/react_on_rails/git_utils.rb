# frozen_string_literal: true

require "English"

module ReactOnRails
  module GitUtils
    def self.uncommitted_changes?(message_handler, git_installed: true)
      return false if ENV["COVERAGE"] == "true"

      status = `git status --porcelain`
      return false if git_installed && status&.empty?

      error = if git_installed
                "You have uncommitted code. Please commit or stash your changes before continuing"
              else
                "You do not have Git installed. Please install Git, and commit your changes before continuing"
              end
      message_handler.add_error(error)
      true
    end
  end
end
