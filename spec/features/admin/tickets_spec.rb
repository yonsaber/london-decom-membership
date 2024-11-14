require 'rails_helper'

RSpec.feature 'Tickets transfer', type: :feature do
  before do
    stub_eventbrite_event
  end

  scenario 'transfer a ticket to another user' do
    create(:event)
    login(admin: true)
    user_a = create(:user, email: 'user_a@example.com', name: 'A User', ticket_bought: false)
    user_a_original_membership_number = user_a.membership_number
    user_b = create(:user, email: 'user_b@example.com', name: 'B User', ticket_bought: true)
    user_b_original_membership_number = user_b.membership_number
    click_link 'Events'
    click_link 'Open'
    click_link 'View Tickets'
    click_link 'Transfer'
    select 'A User (user_a@example.com)', from: 'User to transfer ticket to:'
    click_button 'Transfer Ticket'
    expect(page).to have_content('Ticket was successfully transferred to A User')
    user_a.reload
    user_b.reload
    expect(user_a.ticket_bought).to be_truthy
    expect(user_b.ticket_bought).to be_falsey
    expect(user_a.membership_number).to eq user_b_original_membership_number
    expect(user_b.membership_number).to eq user_a_original_membership_number
  end

  scenario 'cannot transfer tickets if other user has a low income tickets' do
    create(:event)
    login(admin: true)
    create(:user, email: 'user_a@example.com', name: 'A User', ticket_bought: false)
    user_b = create(:user, email: 'user_b@example.com', name: 'B User', ticket_bought: true)
    request = LowIncomeRequest.new(user: user_b, request_reason: 'testing!', status: 'approved')
    request.save!
    click_link 'Events'
    click_link 'Open'
    click_link 'View Tickets'
    expect(page).to_not have_link('Transfer')
  end

  scenario 'cannot transfer tickets if other user has a direct sale tickets' do
    create(:event)
    login(admin: true)
    create(:user, email: 'user_a@example.com', name: 'A User', ticket_bought: false)
    user_b = create(:user, email: 'user_b@example.com', name: 'B User', ticket_bought: true)
    create(:direct_sale_code, user_id: user_b.id)
    click_link 'Events'
    click_link 'Open'
    click_link 'View Tickets'
    expect(page).to_not have_link('Transfer')
  end
end
