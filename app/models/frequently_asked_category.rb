class FrequentlyAskedCategory < ApplicationRecord
  has_many :frequently_asked_questions, foreign_key: 'category_id', dependent: :nullify,
    inverse_of: :category

  validates :name, presence: true
end
