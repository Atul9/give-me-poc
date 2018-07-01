# frozen_string_literal: true

module Web
  module Dashboard
    # Manage ideas
    class IdeasController < BaseController
      before_action :idea_find, only: %i[show edit update activate deactivate reject]
      before_action :authorize_role
      rescue_from Pundit::NotAuthorizedError, with: :redirect_to_dashboard_root

      def index
        @ideas = Web::Dashboard::IdeaPolicy::Scope.new(current_user, ::Idea).resolve.page params[:page]
      end

      def show; end

      def new
        @idea = ::Idea.new
      end

      def create
        result = Ops::Idea::Submit.call(params: idea_params, author: current_user)
        if result.success?
          redirect_to dashboard_ideas_url
        else
          @idea = result[:model]
          render :new
        end
      end

      def edit; end

      def update
        if @idea.update(idea_params)
          redirect_to dashboard_idea_url(@idea),
                      flash: { success: "#{t('dashboard.ideas.update.success')}: #{@idea.name}" }
        else
          flash.now[:danger] = t('dashboard.ideas.update.danger')
          render :edit
        end
      end

      def activate
        Ops::Idea::Activate.call(idea: @idea)
        redirect_to dashboard_idea_url(@idea),
                    flash: { success: "#{t('dashboard.ideas.notice.activated')}: #{@idea.name}" }
      end

      def deactivate
        Ops::Idea::Disable.call(idea: @idea)
        redirect_to dashboard_idea_url(@idea),
                    flash: { success: "#{t('dashboard.ideas.notice.deactivated')}: #{@idea.name}" }
      end

      def reject
        Ops::Idea::Reject.call(idea: @idea)
        redirect_to dashboard_idea_url(@idea),
                    flash: { success: "#{t('dashboard.ideas.notice.rejected')}: #{@idea.name}" }
      end

      private

      def idea_params
        params.require(:idea).permit(:name, :description, :private, :skip_bootstrapping)
      end

      def authorize_role
        authorize %i[web dashboard idea], "#{action_name}?".to_sym
      end

      def idea_find
        @idea = ::Idea.find(params[:id])
      end
    end
  end
end
