require 'rails_helper'

RSpec.feature 'FrequentlyAskedQuestions', type: :feature do
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

  scenario 'when no faqs should only show creation options' do
    stub_eventbrite_event
    login(admin: true)
    click_link 'FAQ Editor'
    expect(page).to have_text('Create New FAQ')
    expect(page).to have_text('Create New Category')
    expect(page).to have_no_text('Delete')
  end

  scenario 'when uncategorized faq exists should show faq' do
    stub_eventbrite_event
    login(admin: true)
    create(
      :frequently_asked_question,
      question: 'What is your favorite color?',
      answer: 'Purple',
      created_by_id: User.first.id
    )
    click_link 'FAQ Editor'
    expect(page).to have_text('What is your favorite color?')
  end

  scenario 'when categorized faq exists should show faq with category link' do
    stub_eventbrite_event
    login(admin: true)
    category = create(:frequently_asked_category, name: 'My Category')
    create(
      :frequently_asked_question,
      question: 'What is your favorite color?',
      answer: 'Purple',
      created_by_id: User.first.id,
      category_id: category.id
    )
    click_link 'FAQ Editor'
    category_name_cell = page.find('#categories > tr:nth-child(2) > td:nth-child(1)')
    linked_qs_count = page.find('#categories > tr:nth-child(2) > td:nth-child(2)')
    expect(category_name_cell).to have_text('My Category')
    expect(linked_qs_count).to have_text('1')
  end

  scenario 'when creating faq should create without error' do
    stub_eventbrite_event
    login(admin: true)
    click_link 'FAQ Editor'
    click_link 'Create New FAQ'
    fill_in 'Question', with: 'What is your favorite color?'
    fill_in 'Answer', with: 'Purple'
    click_button 'Create FAQ Item'
    expect(page).to have_text('What is your favorite color?')
  end

  scenario 'when creating faq category should create without error' do
    stub_eventbrite_event
    login(admin: true)
    click_link 'FAQ Editor'
    click_link 'Create New Category'
    fill_in 'Name', with: 'My Category'
    click_button 'Create FAQ Category'
    expect(page).to have_text('My Category')
  end

  scenario 'when updating faq should update record without error' do
    stub_eventbrite_event
    login(admin: true)
    create(
      :frequently_asked_question,
      question: 'What is your favorite color?',
      answer: 'Purple',
      created_by_id: User.first.id
    )
    click_link 'FAQ Editor'
    expect(page).to have_text('Purple')
    click_link 'Edit'
    fill_in 'Question', with: 'What is your favorite color?'
    fill_in 'Answer', with: 'Pank'
    click_button 'Update FAQ Item'
    expect(page).to have_text('Pank')
  end

  scenario 'when updating faq with category should update record without error' do
    stub_eventbrite_event
    login(admin: true)
    create(:frequently_asked_category, name: 'My Category')
    click_link 'FAQ Editor'
    expect(page).to have_text('My Category')
    click_link 'Edit'
    fill_in 'Name', with: 'My New Category'
    click_button 'Update FAQ Category Item'
    expect(page).to have_text('My New Category')
  end

  scenario 'when moving faq to category should update without error' do
    stub_eventbrite_event
    login(admin: true)
    category = create(:frequently_asked_category, name: 'My Category')
    create(
      :frequently_asked_question,
      question: 'What is your favorite color?',
      answer: 'Purple',
      created_by_id: User.first.id
    )
    click_link 'FAQ Editor'

    category_name_cell = page.find('#categories > tr:nth-child(2) > td:nth-child(1)')
    linked_qs_count = page.find('#categories > tr:nth-child(2) > td:nth-child(2)')
    expect(linked_qs_count).to have_text('0')

    within '#questions' do
      click_link 'Edit', match: :first
    end

    select category.name, from: 'Category'
    click_button 'Update FAQ Item'

    expect(category_name_cell).to have_text('My Category')
    expect(linked_qs_count).to have_text('1')
  end

  scenario 'when moving faq to category with same question should error' do
    stub_eventbrite_event
    login(admin: true)
    category = create(:frequently_asked_category, name: 'My Category')
    create(
      :frequently_asked_question,
      question: 'What is your favorite color?',
      answer: 'Purple',
      created_by_id: User.first.id,
      category_id: category.id
    )
    click_link 'FAQ Editor'

    within '#questions' do
      click_link 'Edit', match: :first
    end

    select category.name, from: 'Category'
    click_button 'Update FAQ Item'

    expect(page).to have_text('Must be a unique question within category')
  end
end
