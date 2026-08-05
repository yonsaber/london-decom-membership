class FrequentlyAskedQuestion < ApplicationRecord
  belongs_to :creator, class_name: 'User', foreign_key: 'created_by_id', optional: true
  belongs_to :updater, class_name: 'User', foreign_key: 'updated_by_id', optional: true
  belongs_to :category, class_name: 'FrequentlyAskedCategory', foreign_key: 'category_id', optional: true

  validates_presence_of :question, :answer
  before_create :validate_unique_question
  before_update :validate_unique_question, if: :category_id_changed?

  def last_modified_by
    last_modifier = updated_by_id.present? ? updater.name : creator.name
    last_modifier.split(' ').first
  end

  private

  def validate_unique_question
    query = FrequentlyAskedQuestion.where('lower(question) = ?', question.downcase)
    has_cat_id = category_id.present?
    if has_cat_id
      query = query.where(category_id: category_id)
    end

    if query.exists?
      errors.add(:question, "Must be a unique question#{has_cat_id ? " within category" : ""}")
    end
  end
end
