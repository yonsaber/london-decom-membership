require 'rails_helper'

RSpec.feature 'Event', type: :feature do
  scenario 'there is no active event' do
    create(:event, active: false)
    login

    expect(page).to have_text('Tickets and volunteering are not live yet')
  end

  scenario 'is active, in draft mode' do
    stub_eventbrite_event(available_tickets_for_code: 0, tickets_sold_for_code: 0)
    create(:event, :draft)
    login

    expect(page).to have_text('Hey James Darling')
    expect(page).to have_text('Tickets and volunteering are not live yet')
  end

  scenario 'is active, in draft mode and user early access' do
    stub_eventbrite_event(available_tickets_for_code: 0, tickets_sold_for_code: 0)
    create(:event, :draft)
    login(early_access: true)

    expect(page).to have_text('Hey James Darling')
    expect(page).to have_text('Tickets and volunteering are not live yet')
  end

  scenario 'is active, in pre-release' do
    stub_eventbrite_event(available_tickets_for_code: 0, tickets_sold_for_code: 0)
    create(:event, :prerelease)
    login

    expect(page).to have_text('Tickets for our next event will be available to buy here soon')
    expect(page).to have_text('Here is the crucial info')
  end

  scenario 'is active, in pre-release and user early access but no tickets' do
    stub_eventbrite_event(available_tickets_for_code: 0, tickets_sold_for_code: 0)
    create(:event, :prerelease, ticket_sale_start_date: nil)
    login(early_access: true)

    expect(page).to have_text('Tickets for our next event will be available to buy here soon')
    expect(page).to have_text('Here is the crucial info')
  end

  scenario 'is active, in pre-release and user early access and has tickets' do
    stub_eventbrite_event(available_tickets_for_code: 1, tickets_sold_for_code: 0)
    create(:event, :prerelease, ticket_sale_start_date: nil)
    login(early_access: true)

    expect(page).to have_text('You can buy 1 ticket.')
    expect(page).to have_text('Here is the crucial info')
  end

  scenario 'is active, in pre-release and with ticket date' do
    stub_eventbrite_event(available_tickets_for_code: 0, tickets_sold_for_code: 0)
    create(:event, :prerelease, ticket_sale_start_date: '2023-10-22 12:00:00.000000000 +0000')
    login

    expect(page).to have_text(
      'Tickets for our next event will be available to buy here on 22/10/2023 at 12:00:00 PM (GMT).'
    )
    expect(page).to have_text('Here is the crucial info')
  end

  scenario 'is active, is live' do
    stub_eventbrite_event(available_tickets_for_code: 0, tickets_sold_for_code: 0)
    create(:event, :live)
    login

    expect(page).to have_text('Tickets for our next event will be available to buy here soon, watch this space!')
    expect(page).to have_text('Here is the crucial info')
  end

  scenario 'is active, is live and with ticket date' do
    stub_eventbrite_event(available_tickets_for_code: 0, tickets_sold_for_code: 0)
    create(:event, :live, ticket_sale_start_date: '2023-10-22 12:00:00.000000000 +0000')
    login

    expect(page).to have_text(
      'Tickets for our next event will be available to buy here on 22/10/2023 at 12:00:00 PM (GMT).'
    )
    expect(page).to have_text('Here is the crucial info')
  end

  scenario 'is active, in live, with ticket date and with ticket' do
    stub_eventbrite_event(available_tickets_for_code: 1, tickets_sold_for_code: 0)
    create(:event, :live, ticket_sale_start_date: '2023-10-22 12:00:00.000000000 +0000')
    login

    expect(page).to have_text('You can buy 1 ticket.')
    expect(page).to have_text('Here is the crucial info')
  end

  scenario 'is active, in live, with sold ticket and available ticket' do
    stub_eventbrite_event(available_tickets_for_code: 1, tickets_sold_for_code: 1)
    create(:event, :live, ticket_sale_start_date: '2023-10-22 12:00:00.000000000 +0000')
    login

    expect(page).to have_text('You have already bought 1 ticket. You can buy 1 more ticket.')
    expect(page).to have_text('Here is the crucial info')
  end

  scenario 'has ended' do
    stub_eventbrite_event(available_tickets_for_code: 0, tickets_sold_for_code: 0)
    create(:event, :ended)
    login

    expect(page).to have_text('Love and Dusty Hugs')
  end
end
