# frozen_string_literal: true

require 'rails_helper'

describe Ops::Idea::Activate do
  subject { described_class }

  describe '#call' do
    let(:idea) { create(:idea, :voting) }
    let(:params) { { idea: idea } }

    it 'changes idea state' do
      expect { subject.call(params) }
        .to change(idea.reload, :state)
        .from('voting').to('active')
    end
  end
end
