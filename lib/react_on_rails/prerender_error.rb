# frozen_string_literal: true

require "rainbow"

# rubocop:disable: Layout/IndentHeredoc
module ReactOnRails
  class PrerenderError < ::ReactOnRails::Error
    MAX_ERROR_SNIPPET_TO_LOG = 1000
    # TODO: Consider remove providing original `err` as already have access to `self.cause`
    # http://blog.honeybadger.io/nested-errors-in-ruby-with-exception-cause/
    attr_reader :component_name, :err, :props, :js_code, :console_messages

    # err might be nil if JS caught the error
    def initialize(component_name: nil, err: nil, props: nil,
                   js_code: nil, console_messages: nil)
      @component_name = component_name
      @err = err
      @props = props
      @js_code = js_code
      @console_messages = console_messages

      backtrace, message = calc_message(component_name, console_messages, err, js_code, props)

      super([message, backtrace].compact.join("\n"))
    end

    def to_honeybadger_context
      to_error_context
    end

    def raven_context
      to_error_context
    end

    def to_error_context
      result = {
        component_name: component_name,
        err: err,
        props: props,
        js_code: js_code,
        console_messages: console_messages
      }

      result.merge!(err.to_error_context) if err.respond_to?(:to_error_context)
      result
    end

    private

    def calc_message(component_name, console_messages, err, js_code, props)
      message = +"ERROR in SERVER PRERENDERING\n"
      if err
        message << <<~MSG
          Encountered error:

          #{err.inspect}

        MSG

        backtrace = if Utils.full_text_errors_enabled?
                      err.backtrace.join("\n")
                    else
                      "#{Rails.backtrace_cleaner.clean(err.backtrace).join("\n")}\n" +
                        Rainbow("The rest of the backtrace is hidden. " \
                                "To see the full backtrace, set FULL_TEXT_ERRORS=true.").red
                    end
      else
        backtrace = nil
      end
      message << <<~MSG
        when prerendering #{component_name} with props: #{Utils.smart_trim(props, MAX_ERROR_SNIPPET_TO_LOG)}

        code:

        #{Utils.smart_trim(js_code, MAX_ERROR_SNIPPET_TO_LOG)}

      MSG

      if console_messages
        message << <<~MSG
          console messages:
          #{console_messages}
        MSG

      end
      [backtrace, message]
    end
  end
end
