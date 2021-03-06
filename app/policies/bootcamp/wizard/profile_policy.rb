# frozen_string_literal: true

module Bootcamp
  module Wizard
    # Defines access rules to profile editing wizard page
    class ProfilePolicy < ApplicationPolicy
      def edit?
        user&.policy_accepted?
      end
    end
  end
end
