class ResumeCertificate < ApplicationRecord
	belongs_to :resume
	has_one :company
end
