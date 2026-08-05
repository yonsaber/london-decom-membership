class Admin::FrequentlyAskedCategoriesController < AdminController
  def new
    @frequently_asked_category = FrequentlyAskedCategory.new
  end

  def edit
    @frequently_asked_category = FrequentlyAskedCategory.find(params.expect(:id))
  end

  def create
    @frequently_asked_category = FrequentlyAskedCategory.new(category_params)
    if @frequently_asked_category.save
      redirect_to admin_frequently_asked_questions_path
    else
      render action: :new
    end
  end

  def update
    @frequently_asked_category = FrequentlyAskedCategory.find(params.expect(:id))
    if @frequently_asked_category.update(category_params)
      redirect_to admin_frequently_asked_questions_path
    else
      render action: :edit
    end
  end

  def destroy
    @frequently_asked_category = FrequentlyAskedCategory.find(params.expect(:id))
    @frequently_asked_category.destroy!
    redirect_to admin_frequently_asked_questions_path
  end

  private

  def category_params
    params.expect(frequently_asked_category: [:name])
  end
end
