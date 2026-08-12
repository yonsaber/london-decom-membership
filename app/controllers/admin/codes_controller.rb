class Admin::CodesController < AdminController
  def index
    respond_to do |f|
      f.html
      f.csv do
        require 'csv'
        code_type = get_code_type(params[:type])
        send_data code_type.all.collect(&:code).join("\n"),
                  filename: "Decom-#{code_type.model_name.human.downcase.gsub! ' ', '-'}-#{Time.zone.today}.csv"
      end
    end
  end

  def create
    code_type = get_code_type(params[:type])

    params[:number].to_i.times do
      code_type.create
    end

    redirect_to action: :index
  end

  private

  def get_code_type(code_type)
    case code_type
    when LowIncomeCode.to_s
      LowIncomeCode
    when MembershipCode.to_s
      MembershipCode
    when DirectSaleCode.to_s
      DirectSaleCode
    else
      raise StandardError, "Unknown code type '#{code_type}'"
    end
  end
end
