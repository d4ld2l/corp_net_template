class AddFileToResumeCertificate < ActiveRecord::Migration[5.0]
  def change
    add_column :resume_certificates, :file, :string
  end
end
