class FrequentlyAskedQuestion < ApplicationRecord
  belongs_to :creator, class_name: 'User', foreign_key: 'created_by_id', optional: true,
             inverse_of: :created_frequently_asked_questions
  belongs_to :updater, class_name: 'User', foreign_key: 'updated_by_id', optional: true,
             inverse_of: :updated_frequently_asked_questions
  belongs_to :category, class_name: 'FrequentlyAskedCategory', optional: true, inverse_of: :frequently_asked_questions

  validates :question, :answer, presence: true
  validate :validate_unique_question

  def last_modified_by
    last_modifier = if updated_by_id.present?
                      updater.name
                    else
                      created_by_id.present? ? creator.name : 'Unknown'
                    end
    last_modifier.split.first
  end

  private

  def validate_unique_question
    query = FrequentlyAskedQuestion.where('lower(question) = ?', question.downcase)
    has_cat_id = category_id.present?
    query = query.where(category_id: category_id) if has_cat_id
    query = query.where(category_id: nil) unless has_cat_id
    possible = query.first
    return if possible.blank?
    return if id.present? && possible.id == id

    errors.add(:question, "Must be a unique question#{' within category' if has_cat_id}")
  end
end
