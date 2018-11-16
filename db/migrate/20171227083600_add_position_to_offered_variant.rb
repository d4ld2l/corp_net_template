class AddPositionToOfferedVariant < ActiveRecord::Migration[5.0]
  def change
    add_column :offered_variants, :position, :integer
  end

  def data
    Question.all.each do |q|
      q.offered_variants.each.with_index(1) do |var, i|
        var.update(position: i)
      end
    end
  end
end
