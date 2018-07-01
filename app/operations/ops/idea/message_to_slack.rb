# frozen_string_literal: true

module Ops
  module Idea
    # Handles all business logic regarding adding new member to GitHub.
    # Besides calling public API, it also markes onboarding step as completed.
    class MessageToSlack < BaseOperation
      step :message_to_slack!

      def message_to_slack!(_ctx, channel:, message:, **)
        SlackService.new(ENV['SLACK_TOKEN']).post_to_channel(channel, message)
        true
      rescue SlackIntegration::FailedApiCallException => e
        handle_exception(e)
      end

      def handle_exception(exception)
        return true if exception.message == 'Unsuccessful send message: { "ok"=>false }'
        raise
      end
    end
  end
end
