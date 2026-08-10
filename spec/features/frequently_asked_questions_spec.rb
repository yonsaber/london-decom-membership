require 'rails_helper'

RSpec.feature 'FrequentlyAskedQuestions', type: :feature do
  scenario 'when no faqs should show empty message' do
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
    expect(page).to have_text('0) What is your favorite color?')
    expect(page).to have_text("Last Updated on #{faq.created_at.to_fs(:decom_standard)} by james")
  end

  scenario 'when categorized faq exists should show faq' do
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
    expect(page).to have_text('0) What is your favorite color?')
    expect(page).to have_text("Last Updated on #{faq.created_at.to_fs(:decom_standard)} by james")
  end
end
