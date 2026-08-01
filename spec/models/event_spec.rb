require 'rails_helper'

RSpec.describe Event do
  scenario 'trying to set low income start after end' do
    event = create(:event)
    event.low_income_requests_end = Time.zone.now
    event.low_income_requests_start = Time.zone.now.advance(weeks: 1)
    expect(event).not_to be_valid
  end

  scenario 'trying to set low income end before start' do
    event = create(:event)
    event.low_income_requests_end = Time.zone.now.advance(weeks: -1)
    event.low_income_requests_start = Time.zone.now
    expect(event).not_to be_valid
  end
end
