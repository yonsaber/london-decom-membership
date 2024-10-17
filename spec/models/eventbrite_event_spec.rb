require 'rails_helper'
require 'webmock/rspec'

RSpec.describe EventbriteEvent, type: :model do
  describe 'set user.ticket_bought' do
    before do
      stub_request(:get, 'https://www.eventbriteapi.com/v3/events/12345/')
        .to_return(status: 200, body: '{ "organization_id": "1234" }')
      uri_template = Addressable::Template.new 'https://www.eventbriteapi.com/v3/organizations/1234/discounts/?code={code}&event_id=12345&scope=event&token=mytoken'
      stub_request(:get, uri_template)
        .to_return(status: 200, body:
          {
            discounts:
              [{
                quantity_available: 1,
                quantity_sold: 0
              }]
          }.to_json)
    end

    it 'to false when ticket not sold' do
      eb = EventbriteEvent.new('mytoken', '12345')
      user = create(:user)
      tickets_sold_for_code = eb.tickets_sold_for_code(user.membership_number)
      user.reload
      expect(tickets_sold_for_code).to be 0
      expect(user.ticket_bought).to be false
    end
  end

  describe 'set user.ticket_bought' do
    before do
      stub_request(:get, 'https://www.eventbriteapi.com/v3/events/12345/')
        .to_return(status: 200, body: '{ "organization_id": "1234" }')
      uri_template = Addressable::Template.new 'https://www.eventbriteapi.com/v3/organizations/1234/discounts/?code={code}&event_id=12345&scope=event&token=mytoken'
      stub_request(:get, uri_template)
        .to_return(status: 200, body:
          {
            discounts:
              [{
                quantity_available: 0,
                quantity_sold: 1
              }]
          }.to_json)
    end

    # NOTE: We have to use .reload to ensure that the expected changes happen e.g. the quantity_sold value being set
    #       or the membership number being changed, there might be a nicer way to do this but so far I'm seeing the
    #       outcomes with values changing so I'm happy

    it 'to true when ticket sold' do
      eb = EventbriteEvent.new('mytoken', '12345')
      user = create(:user)
      tickets_sold_for_code = eb.tickets_sold_for_code(user.membership_number)
      user.reload
      expect(tickets_sold_for_code).to be 1
      expect(user.ticket_bought).to be true
    end

    it 'to true when low income ticket sold' do
      eb = EventbriteEvent.new('mytoken', '12345')
      user = create(:user, email: 'test_mail_user@example.com')
      low_income_request = create(:low_income_request, request_reason: 'Reason 1', user_id: user.id, status: 'approved')
      low_income_code = create(:low_income_code, low_income_request_id: low_income_request.id)
      user.reload
      expect(user.membership_number).to eq(low_income_code.code)
      tickets_sold_for_code = eb.tickets_sold_for_code(user.membership_number)
      user.reload
      expect(tickets_sold_for_code).to be 1
      expect(user.ticket_bought).to be true
    end

    it 'to true when direct sale ticket sold' do
      eb = EventbriteEvent.new('mytoken', '12345')
      user = create(:user, email: 'test_mail_user@example.com')
      direct_sale_code = create(:direct_sale_code, user_id: user.id)
      user.reload
      expect(user.membership_number).to eq(direct_sale_code.code)
      tickets_sold_for_code = eb.tickets_sold_for_code(user.membership_number)
      user.reload
      expect(tickets_sold_for_code).to be 1
      expect(user.ticket_bought).to be true
    end
  end
end
