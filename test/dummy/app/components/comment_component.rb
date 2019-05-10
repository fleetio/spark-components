# frozen_string_literal: true

class CommentComponent < SparkComponents::Component
  attribute :comment

  delegate :user,
           :body, to: :comment
end
