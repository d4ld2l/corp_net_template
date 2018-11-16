class MakeBidsAmountsValid < ActiveRecord::Migration[5.0]
  def change
  end

  def data
    MeetingInformation.all.each do |m|
      if m.amount.present? && m.amount.match(/^[\d\.\,]*$/)
        m.amount = m.amount.gsub(',', '.')
      else
        m.amount = '0'
      end
      m.save(validate:false)
    end
  end
end
