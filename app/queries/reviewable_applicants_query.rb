# frozen_string_literal: true

# Retrieves applicants, that can be reviewed by specific mentor
class ReviewableApplicantsQuery
  attr_reader :mentor

  def initialize(mentor)
    @mentor = mentor
  end

  def call
    User
      .screening_completed
      .joins(:skills)
      .where(user_skills: { skill_id: mentor.primary_skill.id })
  end
end
