class CreateResumeCertificates < ActiveRecord::Migration[5.0]
  def change
    create_table :resume_certificates do |t|
      t.string :name, :limit => 200
      t.integer :company_id
      t.date :start_date
      t.date :end_date      
      t.integer :resume_id

      t.timestamps
    end
  end
end
