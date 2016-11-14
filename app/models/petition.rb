class Petition < ApplicationRecord
  belongs_to :user
  belongs_to :campaign
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :likes, as: :likable, dependent: :destroy
  has_many :signs, dependent: :destroy
  has_many :signed_users, through: :signs, source: :petition, dependent: :destroy

  scope :recent, -> { order('id DESC') }

  def signed? someone
    signed_users.exists?(user: someone)
  end

  def percentage
    ( signs_count.to_f / signs_goal_count * 100 ).to_i
  end
end
