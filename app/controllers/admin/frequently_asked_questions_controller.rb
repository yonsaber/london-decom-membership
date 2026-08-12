class Admin::FrequentlyAskedQuestionsController < AdminController
  def index
    @frequently_asked_questions = FrequentlyAskedQuestion.all
    @categories = FrequentlyAskedCategory.all
  end

  def show
    render action: :index
  end

  def new
    @frequently_asked_question = FrequentlyAskedQuestion.new
  end

  def edit
    @frequently_asked_question = FrequentlyAskedQuestion.find(params.expect(:id))
  end

  def create
    @frequently_asked_question = FrequentlyAskedQuestion.new(frequently_asked_params)
    @frequently_asked_question.created_by_id = current_user.id
    @frequently_asked_question.updated_by_id = current_user.id
    if @frequently_asked_question.save
      redirect_to admin_frequently_asked_questions_path
    else
      render action: :new
    end
  end

  def update
    @frequently_asked_question = FrequentlyAskedQuestion.find(params.expect(:id))
    @frequently_asked_question.updated_by_id = current_user.id
    if @frequently_asked_question.update(frequently_asked_params)
      redirect_to admin_frequently_asked_questions_path
    else
      render action: :edit
    end
  end

  def destroy
    @frequently_asked_question = FrequentlyAskedQuestion.find(params.expect(:id))
    @frequently_asked_question.destroy!
    redirect_to admin_frequently_asked_questions_path
  end

  private

  def frequently_asked_params
    params.expect(frequently_asked_question: [:question, :answer, :category_id])
  end
end
