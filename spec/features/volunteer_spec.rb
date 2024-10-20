require 'rails_helper'

RSpec.feature 'Volunteering', type: :feature do
  scenario "don't have a ticket yet" do
    stub_eventbrite_event(tickets_sold_for_code: 0)
    create(:event)
    login
    expect(page).to_not have_text('Volunteer opportunities')
  end

  scenario 'draft event, cannot see volunteer link' do
    stub_eventbrite_event(tickets_sold_for_code: 0)
    create(:event, :draft)
    login
    expect(page).to_not have_text('Looking to volunteer?')
  end

  scenario 'prerelease event, cannot see volunteer link' do
    stub_eventbrite_event(tickets_sold_for_code: 0)
    create(:event, :prerelease)
    login
    expect(page).to_not have_text('Looking to volunteer?')
  end

  scenario 'prerelease event, early access, can see volunteer link' do
    stub_eventbrite_event(tickets_sold_for_code: 0)
    create(:event, :prerelease)
    login(early_access: true)
    expect(page).to have_text('Looking to volunteer?')
  end

  scenario 'live event, early access, can see volunteer link' do
    stub_eventbrite_event(tickets_sold_for_code: 0)
    create(:event)
    login(early_access: true)
    expect(page).to have_text('Looking to volunteer?')
  end

  scenario 'live event, can see volunteer link' do
    stub_eventbrite_event(tickets_sold_for_code: 0)
    create(:event)
    login
    expect(page).to have_text('Looking to volunteer?')
  end

  scenario 'live event, no ticket, can see volunteer link but cannot apply' do
    create(:volunteer_role, name: 'Ranger', description: 'A description of rangering')
    stub_eventbrite_event(tickets_sold_for_code: 0)
    login
    expect(page).to have_text('Looking to volunteer?')
    click_link 'Volunteering'
    page.assert_no_selector('a', exact_text: 'Volunteer')
  end

  scenario 'live event, buys ticket, can see volunteer link and can apply after buying ticket' do
    create(:volunteer_role, name: 'Ranger', description: 'A description of rangering')
    stub_eventbrite_event(tickets_sold_for_code: 0)
    login
    expect(page).to have_text('Looking to volunteer?')
    click_link 'Volunteering'
    page.assert_no_selector('a', exact_text: 'Volunteer')
    stub_eventbrite_event(tickets_sold_for_code: 1)
    click_link 'Volunteering'
    page.assert_selector('a', exact_text: 'Volunteer')
  end

  scenario 'live event, has ticket, can see volunteer link and can apply' do
    create(:volunteer_role, name: 'Ranger', description: 'A description of rangering')
    stub_eventbrite_event(tickets_sold_for_code: 1)
    login
    expect(page).to have_text('Looking to volunteer?')
    click_link 'Volunteering'
    page.assert_selector('a', exact_text: 'Volunteer')
  end

  scenario 'ended event, early access, cannot see volunteer link' do
    stub_eventbrite_event(tickets_sold_for_code: 0)
    create(:event, :ended)
    login(early_access: true)
    expect(page).to_not have_text('Looking to volunteer?')
  end

  scenario 'signing up to volunteer unsuccessfully' do
    role = create(:volunteer_role, name: 'Ranger', description: 'A description of rangering')
    create(:volunteer, volunteer_role: role, lead: true).user
    stub_eventbrite_event(tickets_sold_for_code: 1)
    login

    click_link 'Volunteering'
    expect(page).to have_text('Ranger')
    click_link 'Volunteer'
    expect(page).to have_text('A description of rangering')
    fill_in 'Phone', with: '07777777'
    fill_in 'Additional comments', with: 'some addition comments'
    click_button 'Volunteer'
    expect(page).to have_selector('#volunteer_accept_code_of_conduct.is-invalid')
    check 'I agree to the Decom Code of Conduct'
    click_button 'Volunteer'
    expect(page).to_not have_selector('#volunteer_accept_code_of_conduct.is-invalid')
    expect(page).to have_selector('#volunteer_accept_health_and_safety.is-invalid')
  end

  scenario 'listing of volunteer roles with limited slots' do
    stub_eventbrite_event(tickets_sold_for_code: 1)
    event = create(:event, :live)

    volunteer_roles = create_list(:volunteer_role, 5) do |vr, i|
      vr.name = "Limited Role #{i + 1}"
      vr.description = 'Limited Role'
      vr.available_slots = (i + 1) * 10
      vr.event = event
      vr.save!
    end

    create_list(:volunteer, 5) do |v, _|
      v.volunteer_role = volunteer_roles[1]
      v.save!
    end

    login

    click_link 'Volunteering'
    expect(page).to have_text('Limited Role 2')
    expect(page).to have_text('15 available slots of 20')
    expect(page).to have_text('Limited Role 3')
    expect(page).to have_text('30 available slots of 30')
  end

  scenario 'signing up to volunteer successfully' do
    role = create(:volunteer_role, name: 'Ranger', description: 'A description of rangering')
    lead = create(:volunteer, volunteer_role: role, lead: true).user
    stub_eventbrite_event(tickets_sold_for_code: 1)
    login

    click_link 'Volunteering'
    expect(page).to have_text('Ranger')
    click_link 'Volunteer'
    expect(page).to have_text('A description of rangering')
    fill_in 'Phone', with: '07777777'
    fill_in 'Additional comments', with: 'some addition comments'
    check 'I agree to the Decom Code of Conduct'
    check "I confirm that I've read the Decom Health and Safety Guidelines"
    click_button 'Volunteer'
    expect(page).to have_text("You've signed up to volunteer for")
    expect(@user.volunteers.count).to eq(1)
    expect(@user.volunteers.first.phone).to eq('07777777')
    expect(@user.volunteers.first.additional_comments).to eq('some addition comments')

    open_email(lead.email)
    expect(current_email).to have_content('James Darling just volunteered for Ranger')

    expect(page).to have_text('The leads for this role should be in contact with you very soon')
    volunteer = @user.volunteers.last
    volunteer.update(state: 'contacted')
    visit event_volunteering_index_path(:event)
    expect(page).to have_text('You have been contacted by a lead')
    volunteer.update(state: 'confirmed')
    visit event_volunteering_index_path(:event)
    expect(page).to have_text('You are confirmed as a volunteer')
  end

  scenario 'signing up to volunteer successfully without leads' do
    create(:volunteer_role, name: 'Ranger', description: 'A description of rangering')
    stub_eventbrite_event(tickets_sold_for_code: 1)
    login

    click_link 'Volunteering'
    expect(page).to have_text('Ranger')
    click_link 'Volunteer'
    expect(page).to have_text('A description of rangering')
    fill_in 'Phone', with: '07777777'
    fill_in 'Additional comments', with: 'some addition comments'
    check 'I agree to the Decom Code of Conduct'
    check "I confirm that I've read the Decom Health and Safety Guidelines"
    click_button 'Volunteer'
    expect(page).to have_text("You've signed up to volunteer for")
    expect(@user.volunteers.count).to eq(1)
    expect(@user.volunteers.first.phone).to eq('07777777')
    expect(@user.volunteers.first.additional_comments).to eq('some addition comments')

    open_email('volunteers@londondecom.org')
    expect(current_email).to have_content('James Darling just volunteered for Ranger')

    expect(page).to have_text('The leads for this role should be in contact with you very soon')
    volunteer = @user.volunteers.last
    volunteer.update(state: 'contacted')
    visit event_volunteering_index_path(:event)
    expect(page).to have_text('You have been contacted by a lead')
    volunteer.update(state: 'confirmed')
    visit event_volunteering_index_path(:event)
    expect(page).to have_text('You are confirmed as a volunteer')
  end

  scenario 'signing up to limited volunteer successfully and update page for other users' do
    role = create(:volunteer_role, name: 'Limited Role', description: 'Limited Role', available_slots: 1)
    create(:volunteer, volunteer_role: role, lead: true).user
    stub_eventbrite_event(tickets_sold_for_code: 1)
    login

    click_link 'Volunteering'
    expect(page).to have_text('Limited Role')
    expect(page).to have_text('1 available slot')
    expect(page).to have_text('Few spaces remain')
    click_link 'Volunteer'
    expect(page).to have_text('Limited Role')
    fill_in 'Phone', with: '07777777'
    fill_in 'Additional comments', with: 'some addition comments'
    check 'I agree to the Decom Code of Conduct'
    check "I confirm that I've read the Decom Health and Safety Guidelines"
    click_button 'Volunteer'
    expect(page).to have_text("You've signed up to volunteer for")
    expect(@user.volunteers.count).to eq(1)
    expect(@user.volunteers.first.phone).to eq('07777777')
    expect(@user.volunteers.first.additional_comments).to eq('some addition comments')

    visit root_path
    click_link 'Logout'

    other_user = create(:user)
    visit root_path
    click_link "Log in if you're already a member"
    fill_in 'Email', with: other_user.email
    fill_in 'Password', with: other_user.password
    click_button 'Log in'

    click_link 'Volunteering'
    expect(page).to have_text('Limited Role')
    expect(page).to have_text('0 available slots')
    expect(page).to have_text('No More Open Slots!')
  end

  scenario 'prevented from applying when visiting direct link with ticket but no slots' do
    role = create(:volunteer_role, name: 'Limited Role', description: 'Limited Role', available_slots: 0)
    create(:volunteer, volunteer_role: role, lead: true).user
    stub_eventbrite_event(tickets_sold_for_code: 1)
    login

    visit new_event_volunteer_role_volunteer_path(:event, role.id)
    expect(page).to have_text('Unfortunately there are no open slots for this role at the moment!')
  end

  scenario 'prevented from applying when visiting direct link with no ticket' do
    role = create(:volunteer_role, name: 'Limited Role', description: 'Limited Role', available_slots: 0)
    create(:volunteer, volunteer_role: role, lead: true).user
    stub_eventbrite_event(tickets_sold_for_code: 1)
    login

    visit new_event_volunteer_role_volunteer_path(:event, role.id)
    expect(page).to have_text('abcd!')
  end

  scenario 'cancelling a volunteering' do
    volunteer_role = create(:volunteer_role, name: 'Ranger', description: 'A description of rangering')
    lead = create(:volunteer, volunteer_role:, lead: true).user
    stub_eventbrite_event(tickets_sold_for_code: 1)
    login
    create(:volunteer, user: @user, volunteer_role:)

    click_link 'Volunteering'
    click_link 'Un-Volunteer'
    expect(page).to have_content('You are no longer volunteering for Ranger')
    expect(@user.volunteers.count).to eq(0)

    open_email(lead.email)
    expect(current_email).to have_content('James Darling has cancelled their volunteering')
  end

  scenario 'no event, no volunteer link' do
    login
    expect(page).to_not have_text('Volunteering')
    expect(page).to_not have_text('Looking to volunteer?')
  end

  scenario 'event in draft mode, no volunteer link' do
    stub_eventbrite_event(tickets_sold_for_code: 0)
    create(:event, :draft)
    login
    expect(page).to_not have_text('Volunteering')
    expect(page).to_not have_text('Looking to volunteer?')
  end

  scenario 'event in pre-release mode, has volunteer link' do
    stub_eventbrite_event(tickets_sold_for_code: 0)
    create(:event, :prerelease)
    login
    expect(page).to have_text('Volunteering')
    expect(page).to_not have_text('Looking to volunteer?')
  end

  scenario 'event in pre-release mode, has volunteer link, across profile page' do
    stub_eventbrite_event(tickets_sold_for_code: 0)
    create(:event, :prerelease)
    login
    expect(page).to have_text('Volunteering')
    expect(page).to_not have_text('Looking to volunteer?')
    click_link 'Profile'
    expect(page).to have_text('Volunteering')
  end

  scenario 'event in pre-release mode, early access, has volunteer link' do
    stub_eventbrite_event(tickets_sold_for_code: 0)
    create(:event, :prerelease)
    login(early_access: true)
    expect(page).to have_text('Volunteering')
    expect(page).to have_text('Looking to volunteer?')
  end

  scenario 'event in pre-release mode, admin, has volunteer link' do
    stub_eventbrite_event(tickets_sold_for_code: 0)
    create(:event, :prerelease)
    login(admin: true)
    expect(page).to have_text('Volunteering')
    expect(page).to have_text('Looking to volunteer?')
  end

  scenario 'event in pre-release mode, early access and admin, has volunteer link' do
    stub_eventbrite_event(tickets_sold_for_code: 0)
    create(:event, :prerelease)
    login(early_access: true, admin: true)
    expect(page).to have_text('Volunteering')
    expect(page).to have_text('Looking to volunteer?')
  end

  scenario 'event in pre-release mode, admin, has volunteer link, across users admin pages' do
    stub_eventbrite_event(tickets_sold_for_code: 0)
    create(:event, :prerelease)
    login(admin: true)
    expect(page).to have_text('Volunteering')
    expect(page).to have_text('Looking to volunteer?')
    click_link 'Users'
    expect(page).to have_text('Volunteering')
  end

  scenario 'event live, has volunteer link' do
    stub_eventbrite_event(tickets_sold_for_code: 0)
    create(:event)
    login
    expect(page).to have_text('Volunteering')
    expect(page).to have_text('Looking to volunteer?')
  end

  scenario 'event live, early access, has volunteer link' do
    stub_eventbrite_event(tickets_sold_for_code: 0)
    create(:event)
    login(early_access: true)
    expect(page).to have_text('Volunteering')
    expect(page).to have_text('Looking to volunteer?')
  end

  scenario 'event live, admin, has volunteer link' do
    stub_eventbrite_event(tickets_sold_for_code: 0)
    create(:event)
    login(admin: true)
    expect(page).to have_text('Volunteering')
    expect(page).to have_text('Looking to volunteer?')
  end

  scenario 'event live, early access and admin, has volunteer link' do
    stub_eventbrite_event(tickets_sold_for_code: 0)
    create(:event)
    login(early_access: true, admin: true)
    expect(page).to have_text('Volunteering')
    expect(page).to have_text('Looking to volunteer?')
  end

  scenario 'event live, admin, has volunteer link across users admin pages' do
    stub_eventbrite_event(tickets_sold_for_code: 0)
    create(:event)
    login(admin: true)
    expect(page).to have_text('Volunteering')
    expect(page).to have_text('Looking to volunteer?')
    click_link 'Users'
    expect(page).to have_text('Volunteering')
  end

  scenario 'event ended, no volunteer link' do
    stub_eventbrite_event(tickets_sold_for_code: 0)
    create(:event, :ended)
    login
    expect(page).to_not have_text('Volunteering')
    expect(page).to_not have_text('Looking to volunteer?')
  end

  scenario 'event ended, early access, no volunteer link' do
    stub_eventbrite_event(tickets_sold_for_code: 0)
    create(:event, :ended)
    login(early_access: true)
    expect(page).to_not have_text('Volunteering')
    expect(page).to_not have_text('Looking to volunteer?')
  end

  scenario 'event ended, admin, no volunteer link' do
    stub_eventbrite_event(tickets_sold_for_code: 0)
    create(:event, :ended)
    login(admin: true)
    expect(page).to_not have_text('Volunteering')
    expect(page).to_not have_text('Looking to volunteer?')
  end

  scenario 'event ended, early access and admin, no volunteer link' do
    stub_eventbrite_event(tickets_sold_for_code: 0)
    create(:event, :ended)
    login(early_access: true, admin: true)
    expect(page).to_not have_text('Volunteering')
    expect(page).to_not have_text('Looking to volunteer?')
  end
end
