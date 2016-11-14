# frozen_string_literal: true

# Evaluates all answers associated with the given question.
# Call this service after the package of the question is updated.
class Course::Assessment::Question::AnswersEvaluationService
  # @param [Course::Assessment::Question] question The programming question.
  def initialize(question)
    @question = question
  end

  def call
    @question.answers.without_attempting_state.each(&:auto_grade!)
  end
end
