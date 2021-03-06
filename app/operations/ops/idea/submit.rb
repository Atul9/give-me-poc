# frozen_string_literal: true

module Ops
  module Idea
    # This operation create idea
    class Submit < BaseOperation
      step Model(::Idea, :new)
      step :assign_current_user!
      step Contract::Build(constant: ::Propose::ProposeForm)
      step Contract::Validate()
      step Contract::Persist()
      step :send_message_to_slack!

      private

      def assign_current_user!(_ctx, params:, author:, **)
        params[:author_id] = author.id
      end

      def send_message_to_slack!(_ctx, model:, **)
        SlackMessageJob.perform_later(model, 'ideas')
        true
      end
    end
  end
end
