class FrequentlyAskedQuestionsController < ApplicationController
  def index
    @categories = FrequentlyAskedCategory.all
    @uncategorized_questions = FrequentlyAskedQuestion.where(category_id: nil)
  end
end
