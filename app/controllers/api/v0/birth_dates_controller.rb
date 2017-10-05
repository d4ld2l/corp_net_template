class Api::V0::BirthDatesController < Api::BaseController
  include ActionController::ImplicitRender
  respond_to :json
  layout false

  def index
    @collection = {}
    collection = Profile.where.not(birthday: nil).group_by(&:birthday)
    collection.each do |date, profiles|
      date = date.change(year: Date.current.year)
      if @collection[date].present?
        @collection[date] |= profiles
      else
        @collection[date] = profiles
      end
    end

    render
  end

  def nearest
    @collection = {}
    today = Date.current
    collection = Profile.where.not(birthday: nil).group_by(&:birthday)
    collection.each do |date, profiles|
      (0..1).each do |year_shift|
        date = date.change(year: today.year+year_shift)
        if @collection[date].present?
          @collection[date] |= profiles
        else
          @collection[date] = profiles
        end
      end
    end
    @result = Hash[*@collection.reject{|k,v| k < Date.current}.sort.first]
    render
  end

  def show
    @resource_instance = Profile.where(birthday: params[:birthday])

    render
  end
end
