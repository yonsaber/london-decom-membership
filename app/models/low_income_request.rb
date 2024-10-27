class LowIncomeRequest < ApplicationRecord
  belongs_to :user
  has_one :low_income_code, dependent: :destroy

  def approve!
    update(status: 'approved')
    LowIncomeCode.available.first.update(low_income_request: self)
  end

  def reject!
    update(status: 'rejected')
  end

  def self.to_csv
    require 'csv'

    CSV.generate(headers: true) do |csv|
      csv << %w[Name Email LI\ Request\ Status Ticket\ Bought Created\ At Last\ Updated\ At]

      all.each do |lir|
        csv << [
          lir.user.name,
          lir.user.email,
          lir.status&.capitalize || 'No Current Status',
          lir.user.ticket_bought ? 'Yes' : 'No',
          lir.created_at.to_fs(:decom_standard),
          lir.updated_at.to_fs(:decom_standard)
        ]
      end
    end
  end
end
