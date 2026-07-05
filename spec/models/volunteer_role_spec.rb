require 'rails_helper'

RSpec.describe VolunteerRole do
  describe '.available_for_user' do
    let!(:user) { create(:user) }
    let!(:first_volunteer_role) { create(:volunteer_role) }
    let!(:second_volunteer_role) { create(:volunteer_role) }

    it 'filters out roles that a user has already signed up for' do
      create(:volunteer, user:, volunteer_role: first_volunteer_role)
      expect(described_class.available_for_user(user).all).to eq([second_volunteer_role])
    end

    it 'returns all if user has no volunteers' do
      expect(described_class.available_for_user(user).all).to eq([first_volunteer_role, second_volunteer_role])
    end
  end
end
