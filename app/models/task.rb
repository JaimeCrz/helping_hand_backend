# frozen_string_literal: true

class Task < ApplicationRecord
  validates_presence_of :status, :long, :lat

  has_many :task_items, dependent: :delete_all
  belongs_to :user
  belongs_to :provider, class_name: 'User', foreign_key: 'provider_id', optional: true
  enum status: %i[pending confirmed claimed delivered finalized]

  def is_confirmable?
    task_items.count < 40 && task_items.count >= 5
  end

  def is_claimable?(user)
    status != 'claimed' && self.user != user
  end

  def is_deliverable?(user)
    status != 'delivered' && self.provider == user
  end

  def is_finalizable?(user)
    status == 'delivered' && self.user == user
  end

  def is_declinable?(user)
    status == 'claimed' && self.provider == user
  end

  def is_deletable?(user)
    (status == 'confirmed' || status == 'pending') && self.user == user
  end
end
