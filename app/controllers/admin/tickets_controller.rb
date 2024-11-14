class Admin::TicketsController < AdminController
  def index
    low_income_users = LowIncomeRequest.where(status: 'approved').select(:user_id)
    direct_sale_users = DirectSaleCode.where.not(user_id: nil).select(:user_id)
    @users = User.confirmed
                 .where(ticket_bought: true)
                 .where.not(id: low_income_users)
                 .where.not(id: direct_sale_users)
                 .order(:created_at)
    paginate(params[:q], params[:page])
  end

  def edit
    membership_code = MembershipCode.find_by(code: params[:id])
    @membership_code = membership_code.code
    @user = User.find_by(id: membership_code.user_id)
    low_income_users = LowIncomeRequest.where(status: 'approved').select(:user_id)
    direct_sale_users = DirectSaleCode.where.not(user_id: nil).select(:user_id)
    @users = User.confirmed.where(ticket_bought: false).where.not(id: low_income_users).where.not(id: direct_sale_users)
  end

  def update
    from_user = User.find(params[:user_from_id])
    to_user = User.find(params[:user_to_id])
    switch_users_memberships(from_user, to_user, params[:id])
    update_user_accounts(from_user, to_user)
    flash[:notice] = "Ticket was successfully transferred to #{to_user.name}"
    Rails.logger.info(
      "[TICKET TRANSFER] #{current_user.name} transferred ticket from user #{from_user.id} to #{to_user.id}"
    )
    redirect_to action: :index
  end

  private

  def paginate(query, page_no)
    if query
      q = "%#{query}%"
      @users = @users.where('name ILIKE ? OR email ILIKE ?', q, q).page page_no
    else
      @users = @users.page page_no
    end
  end

  # This is fucky, basically we get the membership code we are looking at e.g ABC, we then grab the membership code
  # of the second user e.g. XZY, the we change the user IDs against the membership codes so that, as far as the system
  # thinks, the ticket was transferred between the two users. I don't think this is the BEST solution in the world
  # but does allow us to transfer tickets on the site and have limited issues with it
  def switch_users_memberships(transfer_from_user, transfer_to_user, membership_code)
    code_with_ticket = MembershipCode.find_by(code: membership_code)
    code_without_ticket = MembershipCode.find_by(code: transfer_to_user.membership_number)

    code_without_ticket.user_id = transfer_from_user.id
    code_with_ticket.user_id = transfer_to_user.id

    code_without_ticket.save!
    code_with_ticket.save!
  end

  def update_user_accounts(transfer_from_user, transfer_to_user)
    transfer_from_user.ticket_bought = false
    transfer_to_user.ticket_bought = true
    transfer_from_user.save!
    transfer_to_user.save!
  end
end
