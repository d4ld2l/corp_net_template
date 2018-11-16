class AddPositionToQuestion < ActiveRecord::Migration[5.0]
  def data
    Survey.all.each do |survey|
      survey.questions.order(:updated_at).each.with_index(1) do |question, index|
        question.update_column :position, index
      end
    end
  end

  def up
    add_column :questions, :position, :integer
  end

  def down
    remove_column :questions, :position, :integer
  end

end
