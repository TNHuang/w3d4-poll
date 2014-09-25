class Response < ActiveRecord::Base
  validates :user_id, :answer_id, presence: true

  validate :respondent_has_not_already_answered_question
  validate :does_not_respond_to_own_poll

  belongs_to :answer_choice,
  class_name: "AnswerChoice",
  foreign_key: :answer_id,
  primary_key: :id

  belongs_to :respondent,
  class_name: "User",
  foreign_key: :user_id,
  primary_key: :id

  has_one :question, through: :answer_choice, source: :question

  has_one :poll, through: :question, source: :poll

  def sibling_responses1
    return self.question.responses if self.id.nil?

    self.question.responses.
    where("responses.id != ?", self.id)
  end

  def sibling_responses
    self.question.responses.
    where('responses.id = ?', self.id).
    where('(:id IS NULL) OR (responses.id != :id)', id: self.id)

  end

  def respondent_has_not_already_answered_question
    if sibling_responses.exists?(user_id: self.user_id)
      errors[:base] << "user already answered question"
    end
  end

  def does_not_respond_to_own_poll
    self_responses = Response.
    joins("INNER JOIN answer_choices ON responses.answer_id = answer_choices.id").
    joins("INNER JOIN questions ON answer_choices.question_id = questions.id").
    joins("INNER JOIN my_polls ON questions.poll_id = my_polls.id").
    where("my_polls.author_id = ?", self.user_id)

    unless self_responses.empty?
      errors[:base] << "author cannot respond to own poll"
    end
  end
  #author cant respond
  # def has_not_already_answered_question?
  #   if Response.where("question_id = ?", self.question_id).exists?(user_id: self.user_id)
  #     errors[:base] << "user has already answered this question"
  #   end
  # end
  #
  # def self.sibling_responses
  #   Response.where("question_id = ?", self.question_id)
  # end
end