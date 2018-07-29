# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Roles::Author do
  subject(:role) { build_stubbed(:role, :author) }

  describe 'role default state' do
    it 'is pending' do
      expect(role).to have_state(:pending)
    end
  end

  describe 'changes in role states' do
    it 'accept policy' do
      expect(role)
        .to transition_from(:pending).to(:policy_accepted)
                                     .on_event(:accept_policy)
    end

    it 'completes profile' do
      expect(role)
        .to transition_from(:policy_accepted).to(:profile_completed).on_event(:complete_profile)
    end

    it 'activate role' do
      expect(role)
        .to transition_from(:profile_completed).to(:active)
                                               .on_event(:activate)
      expect(role)
        .to transition_from(:disabled).to(:active)
                                      .on_event(:activate)
    end

    it 'disable role' do
      expect(role)
        .to transition_from(:active).to(:disabled)
                                    .on_event(:disable)
    end

    it 'reject role' do
      expect(role).to transition_from(:profile_completed).to(:rejected).on_event(:reject)
    end
  end
end
