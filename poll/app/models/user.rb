class User < ActiveRecord::Base
  validates :user_name, presence: true, uniqueness: true

  has_many :authored_polls,
  class_name: "MyPoll",
  foreign_key: :author_id,
  primary_key: :id

  has_many :responses,
  class_name: "Response",
  foreign_key: :user_id,
  primary_key: :id

  has_many :responded_polls,
  through: :responses,
  source: :poll

  def sql_completed_polls
    sql = <<-SQL
    SELECT
    my_polls.*
    FROM
    my_polls
    LEFT OUTER JOIN
    questions
    ON
    questions.poll_id = my_polls.id
    INNER JOIN
    answer_choices
    ON
    answer_choices.question_id = questions.id
    INNER JOIN
    responses
    ON
    answer_choices.id = responses.answer_id
    WHERE responses.user_id = ?
    GROUP BY my_polls.id
    HAVING COUNT(responses.id) = COUNT(questions.id)
    SQL

    MyPoll.find_by_sql([sql, self.id])
  end

  def completed_polls

    completed_polls = MyPoll.
    joins("LEFT OUTER JOIN questions ON questions.poll_id = my_polls.id").
    joins("INNER JOIN answer_choices ON answer_choices.question_id = questions.id").
    joins("INNER JOIN responses ON answer_choices.id = responses.answer_id").
    where(["responses.user_id = ?", self.id]).
    group("my_polls.id").
    having("COUNT(responses.id) = COUNT(questions.id)")

    completed_polls
  end
end