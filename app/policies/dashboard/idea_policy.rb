# frozen_string_literal: true

module Dashboard
  # Policy manage ideas, full access staff and mentor
  class IdeaPolicy < DashboardPolicy
    def index?
      true
    end

    def show?
      current_user_allow_show?
    end

    def new?
      not_developer?
    end

    alias create? new?

    def edit?
      current_user_allow_edit?
    end

    alias update? edit?

    def voting?
      current_user_allow_voting?
    end

    def activate?
      current_user_allow_activate?
    end

    def deactivate?
      current_user_allow_deactivate?
    end

    def reject?
      current_user_allow_reject?
    end

    def manage?
      staff_or_mentor?
    end

    private

    def current_user_allow_show?
      staff_or_mentor? || record.voting? && developer? || record.author == user
    end

    def current_user_allow_edit?
      staff_or_mentor? || author? && record.author == user
    end

    def current_user_allow_voting?
      record.pending? && staff_or_mentor?
    end

    def current_user_allow_activate?
      (record.disabled? || record.voting?) && staff_or_mentor?
    end

    def current_user_allow_deactivate?
      record.active? && staff_or_mentor?
    end

    def current_user_allow_reject?
      (record.pending? || record.voting?) && staff_or_mentor?
    end

    # Defines a scope of Ideas, who can be available for acting person
    class Scope < Scope
      def resolve
        if all_ideas?
          ::Idea.all
        elsif voting_and_current_user_ideas?
          ::Idea.where('author_id = ? OR state = ?', user.id, 'voting')
        elsif current_user_ideas?
          ::Idea.where(author_id: user.id)
        elsif active_ideas?
          ::Idea.voting
        end
      end

      private

      def all_ideas?
        user.has_role?(:staff) || user.has_role?(:mentor)
      end

      def voting_and_current_user_ideas?
        user.has_role?(:developer) && user.has_role?(:author)
      end

      def current_user_ideas?
        user.has_role? :author
      end

      def active_ideas?
        user.has_role? :developer
      end
    end
  end
end
