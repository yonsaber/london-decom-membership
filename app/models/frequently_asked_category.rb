class FrequentlyAskedCategory < ApplicationRecord
  has_many :frequently_asked_questions, foreign_key: 'category_id', dependent: :nullify

  validates_presence_of :name
end
