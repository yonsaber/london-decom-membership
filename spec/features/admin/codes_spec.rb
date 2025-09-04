require 'rails_helper'

RSpec.feature 'Membership Code Admin', type: :feature do
  scenario 'should list existing codes, and can generate more' do
    # 10 low income codes are generated in spec_helper.rb
    stub_eventbrite_event
    # A used membership code is generated when we create this admin user
    login(admin: true)
    visit admin_codes_path
    expect(page).to have_text('There are 10 codes left')
    expect(page).to have_text('No codes have been assigned')
    fill_in 'low-income-code-number', with: '1'
    click_button 'low-income-code-create'
    expect(page).to have_text('There are 11 codes left')
    expect(page).to have_text('No codes have been assigned')
  end

  scenario 'should list existing codes, and can generate more' do
    # 10 low income codes are generated in spec_helper.rb
    stub_eventbrite_event
    # A used membership code is generated when we create this admin user
    login(admin: true)
    visit admin_codes_path
    expect(page).to have_text('There are 11 codes left')
    expect(page).to have_text('1 code has been assigned')
    fill_in 'membership-code-number', with: '2'
    click_button 'membership-code-create'
    expect(page).to have_text('There are 13 codes left')
    expect(page).to have_text('1 code has been assigned')
  end

  scenario 'as not an admin' do
    stub_eventbrite_event
    login(admin: false)
    visit admin_codes_path
    expect(page).to have_text('You are not permitted to view this')
  end
end
