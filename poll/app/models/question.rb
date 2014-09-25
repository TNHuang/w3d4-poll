class Question < ActiveRecord::Base
  validates :poll_id, :text, presence: true

  has_many :answer_choices,
  class_name: "AnswerChoice",
  foreign_key: :question_id,
  primary_key: :id

  belongs_to :poll,
  class_name: "MyPoll",
  foreign_key: :poll_id,
  primary_key: :id

  has_many :responses, through: :answer_choices, source: :responses

  def slow_results
    result = {}

    answer_choices.each do |answer|
      result[answer.text] = answer.responses.count
    end
    result
  end

  def medium_results
    result = {}
    choices_with_responses = answer_choices.includes(:responses)
    choices_with_responses.each do |answer|
      result[answer.text] = answer.responses.length
    end
    result
  end

  def sql_results
    sql = <<-SQL
    SELECT
      answer_choices.* , COUNT(responses.id) AS responses_count
    From
      answer_choices
    LEFT OUTER JOIN
      responses
    ON
      answer_choices.id = responses.answer_id
    WHERE
      answer_choices.question_id = ?
    GROUP BY
      answer_choices.id

    SQL
    result = {}

    Question.find_by_sql( [sql, self.id] ).each do |answer|
      result[answer.text] = answer.responses_count
    end
    result

  end

  def results
    result = {}

    answer_choices_with_count = answer_choices
    .select("answer_choices.* , COUNT(responses.id) AS responses_count")
    .joins("LEFT OUTER JOIN responses ON answer_choices.id = responses.answer_id")
    .where("answer_choices.question_id = ?", self.id)
    .group("answer_choices.id")

    answer_choices_with_count.each do |answer|
      result[answer.text] = answer.responses_count
    end

    result
  end


end