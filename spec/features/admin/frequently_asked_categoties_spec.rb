require 'rails_helper'

RSpec.feature 'FrequentlyAskedCategories', type: :feature do
  scenario 'when user not admin, editor should not show' do
    stub_eventbrite_event
    login
    expect(page).to have_no_text('FAQ Editor')
  end

  scenario 'when user admin, editor should show' do
    stub_eventbrite_event
    login(admin: true)
    expect(page).to have_text('FAQ Editor')
  end

  scenario 'when no faqs should show' do
    stub_eventbrite_event
    login
    click_link 'FAQ'
    expect(page).to have_text('There are currently no FAQs in the system!')
  end

  scenario 'when uncategorized faq exists should show faq' do
    stub_eventbrite_event
    login
    faq = create(
      :frequently_asked_question,
      question: 'What is your favorite color?',
      answer: 'purple',
      created_by_id: User.first.id
    )
    click_link 'FAQ'
    expect(page).to have_text('1) What is your favorite color?')
    expect(page).to have_text("Last Updated on #{faq.created_at.to_fs(:decom_standard)} by james")
  end

  scenario 'when categorized faq exists should show faq categorized' do
    stub_eventbrite_event
    login
    category = create(:frequently_asked_category, name: 'My Category')
    faq = create(
      :frequently_asked_question,
      question: 'What is your favorite color?',
      answer: 'purple',
      created_by_id: User.first.id,
      category_id: category.id
    )
    click_link 'FAQ'
    expect(page).to have_text('My Category')
    expect(page).to have_text('1) What is your favorite color?')
    expect(page).to have_text("Last Updated on #{faq.created_at.to_fs(:decom_standard)} by james")
  end
end
