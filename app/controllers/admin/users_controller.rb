class Admin::UsersController < AdminController
  def index
    if params[:q]
      q = "%#{params[:q]}%"
      @users = User.confirmed.where('name ILIKE ? OR email ILIKE ?', q, q).order(:created_at).page params[:page]
    else
      @users = User.confirmed.order(:created_at).page params[:page]
    end
  end

  def unconfirmed
    if params[:q]
      q = "%#{params[:q]}%"
      @users = User.unconfirmed.where('name ILIKE ? OR email ILIKE ?', q, q).order(:created_at).page params[:page]
    else
      @users = User.unconfirmed.order(:created_at).page params[:page]
    end
  end

  def edit
    @user = User.find(params[:id])
    event = Event.active(early_access: @user.early_access)
    return if event.nil?

    @has_cache_entry = Rails.cache.exist?(
      "eventbrite:event:#{event.eventbrite_id}:discounts:#{@user.membership_number}"
    )
  end

  def update
    @user = User.find(params[:id])
    @user.update!(user_params)
    @user.update_mailchimp
    redirect_to action: :index
  end

  def resend_email
    @user = User.find(params[:id])
    @user.resend_confirmation_instructions
    redirect_to action: :unconfirmed
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    if @user.confirmed?
      redirect_to action: :index
    else
      redirect_to action: :unconfirmed
    end
  end

  def give_direct_sale
    @user = User.find(params[:id])
    direct_sale_code = DirectSaleCode.available.first
    direct_sale_code.update(user: @user)
    redirect_to edit_admin_user_path(@user)
  end

  def admin_clear_discount_from_cache
    @user = User.find(params[:id])
    event = Event.active(early_access: @user.early_access)
    return if event.nil? || @user.nil?

    deleted = Rails.cache.delete("eventbrite:event:#{event.eventbrite_id}:discounts:#{@user.membership_number}")
    if deleted
      flash[:notice] = 'Successfully cleared user ticket!'
    else
      flash[:alert] = 'There was an issue clearing the user ticket, please contact members@londondecom.org'
    end

    redirect_to edit_admin_user_path(@user)
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :admin, :early_access, :marketing_opt_in)
  end
end
