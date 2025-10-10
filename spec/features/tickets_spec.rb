require 'rails_helper'

RSpec.feature 'Tickets', type: :feature do
  scenario 'there is no active event' do
    login
    create(:event, active: false)

    expect(page).to have_text('Tickets and volunteering are not live yet')
  end

  scenario 'there is no active event, but the member has early access' do
    stub_eventbrite_event(available_tickets_for_code: 1, tickets_sold_for_code: 0)
    create(:event, active: false)
    login(early_access: true)

    expect(page).to have_text('Buy Ticket')
    expect(page).to have_text('You can buy 1 ticket')
  end

  scenario 'user has 1 available tickets and bought none' do
    stub_eventbrite_event(available_tickets_for_code: 1, tickets_sold_for_code: 0)
    create(:event)
    login

    expect(page).to have_text('Buy Ticket')
    expect(page).to have_text('You can buy 1 ticket')
  end

  scenario 'user has no available tickets' do
    stub_eventbrite_event(available_tickets_for_code: 0, tickets_sold_for_code: 0)
    create(:event)
    login

    expect(page).to_not have_text('Buy Ticket')
    expect(page).to have_text('There are no tickets available')
  end

  scenario 'user has bought only ticket' do
    stub_eventbrite_event(available_tickets_for_code: 0, tickets_sold_for_code: 1)
    create(:event)
    login

    expect(page).to_not have_text('Buy Ticket')
    expect(page).to have_text('You have bought the 1 ticket available to you')
  end

  scenario 'user has 2 available tickets' do
    stub_eventbrite_event
    create(:event)
    login

    expect(page).to have_text('Buy Ticket')
    expect(page).to have_text('You can buy 2 tickets')
  end

  scenario 'user has 1 available tickets and bought 1' do
    stub_eventbrite_event(available_tickets_for_code: 1, tickets_sold_for_code: 1)
    create(:event)
    login

    expect(page).to have_text('Buy Ticket')
    expect(page).to have_text('You have already bought 1 ticket. You can buy 1 more ticket')
  end

  scenario 'user has 1 available tickets but ticket class is not on sale' do
    stub_eventbrite_event(available_tickets_for_code: 1, tickets_sold_for_code: 0, ticket_class_on_sale?: false)
    create(:event)
    login

    expect(page).to_not have_text('Buy Ticket')
    expect(page).to have_text('Tickets are not currently on sale')
  end

  scenario 'user has 1 available tickets but in a sold out ticket class' do
    stub_eventbrite_event(available_tickets_for_code: 1, tickets_sold_for_code: 0, ticket_class_sold_out?: true)
    create(:event)
    login

    expect(page).to_not have_text('Buy Ticket')
    expect(page).to have_text('Tickets are sold out')
  end
end
