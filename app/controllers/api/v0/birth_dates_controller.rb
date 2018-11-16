class Api::V0::BirthDatesController < Api::BaseController
  include Api::V0::BirthDates
  before_action :authenticate_account!

  def index
    @collection = {}
    collection = Account.includes(chain_collection_inclusion).where.not(birthday: nil).group_by(&:birthday)
    collection.each do |date, accounts|
      date = date.change(year: Date.current.year)
      if @collection[date].present?
        @collection[date] |= accounts.as_json(json_collection_inclusion)
      else
        @collection[date] = accounts.as_json(json_collection_inclusion)
      end
    end

    render json: @collection
  end

  def nearest
    dates_arr = Account.where.not(birthday: nil).pluck(:birthday).uniq
    dates_arr_with_shift = []
    today = Date.current
    dates_arr.each do |d|
      (0..1).each do |year_shift|
        dates_arr_with_shift << d.change(year: today.year + year_shift)
      end
    end
    nearest_date = dates_arr_with_shift.select { |x| x >= Date.today }.min
    @collection = Account.where.not(birthday: nil)
                         .where('extract(month from birthday) = extract(month from date ?)', nearest_date)
                         .where('extract(day from birthday) = extract(day from date ?)', nearest_date)
                         .includes(chain_resource_inclusion)

    render json: {
      "#{nearest_date.to_date}": @collection.as_json(json_resource_inclusion)
    }
  end

  def show
    @resource_instance = Account.where(birthday: params[:birthday])
    render json: @resource_instance
  end
end
