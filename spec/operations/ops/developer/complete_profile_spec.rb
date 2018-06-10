# frozen_string_literal: true

require 'rails_helper'

describe Ops::Developer::CompleteProfile do
  subject { described_class }

  describe '.call' do
    let(:user) { create(:user, :policy_accepted) }
    let(:skill) { create(:skill) }
    let(:skill_params) { { primary_skill_id: skill.id } }

    context 'valid profile data provided' do
      let(:profile_params) { valid_user_attributes }
      let(:params) { profile_params.merge(skill_params) }

      it 'updates profile' do
        expect { subject.call(user: user, params: params) }
          .to change(user.reload, :first_name)
          .to(params[:first_name])
      end

      it 'changes user state' do
        expect { subject.call(user: user, params: params) }
          .to change(user.reload, :state)
          .to('profile_completed')
      end

      it 'creates primary user skill' do
        expect { subject.call(user: user, params: params) }
          .to change { user.reload.primary_skill }
          .from(nil)
          .to(skill)
      end

      it 'calls StartScreening operation' do
        expect(Ops::Developer::Screening::Start)
          .to receive(:call)
          .with(user: user)
        subject.call(user: user, params: params)
      end
    end

    context 'invalid provided data' do
      let(:invalid_profile_params) do
        {
          first_name: nil
        }
      end
      let(:params) { invalid_profile_params.merge(skill_params) }

      it 'does not update profile' do
        expect { subject.call(user: user, params: params) } # rubocop:disable Lint/AmbiguousBlockAssociation
          .not_to change { user.reload.first_name }
      end

      it 'does not change user state' do
        expect { subject.call(user: user, params: params) }
          .not_to change(user.reload, :state)
      end

      it 'does not create primary skill for user' do
        expect { subject.call(user: user, params: params) }
          .not_to change(user.reload, :primary_skill)
      end

      it 'does not call StartScreening operation' do
        expect(Ops::Developer::Screening::Start)
          .not_to receive(:call)
          .with(user: user)
        subject.call(user: user, params: params)
      end
    end
  end
end
