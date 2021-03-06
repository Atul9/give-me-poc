# frozen_string_literal: true

module Web
  module Dashboard
    # Handles all management logic for newcomers
    class TestTaskAssignmentsController < BaseController
      before_action :candidate, only: %i[show activate reject]
      before_action :authorize_staff!, only: :index

      def index
        @candidates = TestTaskAssignmentPolicy::Scope.new(current_user, User).resolve
      end

      def show; end

      def activate
        Ops::Developer::Activate.call(user: @candidate, performer: current_user.id)
        redirect_to dashboard_test_task_assignments_url,
                    flash: { success: "#{t('dashboard.candidates.notices.activated')}: #{@candidate.email}" }
      end

      def reject
        Ops::Developer::Reject.call(user: @candidate, feedback: rejection_params[:feedback])
        redirect_to dashboard_test_task_assignments_url,
                    flash: { success: "#{t('dashboard.candidates.notices.rejected')}: #{@candidate.email}" }
      end

      private

      def candidate
        @candidate ||= authorize User.find(params[:id]), policy_class: TestTaskAssignmentPolicy
      end

      def authorize_staff!
        authorize :test_task_assignment, "#{action_name}?".to_sym
      end

      def rejection_params
        params.require(:developer_test_task_assignment).permit(:feedback)
      end
    end
  end
end
