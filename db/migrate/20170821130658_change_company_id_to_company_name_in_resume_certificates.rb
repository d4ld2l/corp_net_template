class ChangeCompanyIdToCompanyNameInResumeCertificates < ActiveRecord::Migration[5.0]
  def change
    remove_column :resume_certificates, :company_id, :integer
    add_column :resume_certificates, :company_name, :string
  end
end
