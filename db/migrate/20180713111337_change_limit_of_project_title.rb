class ChangeLimitOfProjectTitle < ActiveRecord::Migration[5.0]
  def change
    change_column :projects, :title, :string, limit: 1024
  end
end
