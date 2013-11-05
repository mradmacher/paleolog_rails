class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true
  belongs_to :user

  MESSAGE_COLS = 60
  MESSAGE_ROWS = 8

  validates_presence_of :message
end
