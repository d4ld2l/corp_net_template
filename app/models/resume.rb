class Resume < ApplicationRecord
	belongs_to :user, required: false
	has_many :professional_specializations_resumes
	has_many :professional_specializations, through: :professional_specializations_resumes
	# has_and_belongs_to_many :professional_specializations
	has_many :resume_certificates, dependent: :destroy #?
	has_many :resume_experiences, dependent: :destroy #?
	has_many :resume_skills, dependent: :destroy #?
	has_many :additional_contacts, dependent: :destroy
	has_many :language_skills
	has_many :resume_work_experiences
	has_many :resume_recommendations
	has_many :resume_educations

	accepts_nested_attributes_for :resume_work_experiences, reject_if: :all_blank, allow_destroy: true
	accepts_nested_attributes_for :additional_contacts, reject_if: :all_blank, allow_destroy: true
	accepts_nested_attributes_for :language_skills, reject_if: :all_blank, allow_destroy: true
	accepts_nested_attributes_for :resume_recommendations, reject_if: :all_blank, allow_destroy: true
	accepts_nested_attributes_for :resume_certificates, reject_if: :all_blank, allow_destroy: true
	accepts_nested_attributes_for :resume_educations, reject_if: :all_blank, allow_destroy: true
	accepts_nested_attributes_for :professional_specializations, reject_if: :all_blank, allow_destroy: true
	accepts_nested_attributes_for :professional_specializations_resumes, reject_if: :all_blank, allow_destroy: true

	validates_length_of :professional_specializations, maximum: 3

	enum preferred_contact_type: [:phone, :email, :skype], _suffix: true
	enum sex: [:male, :female, :undefined], _suffix: true
	enum martial_condition: [:never_married, :married, :divorced], _suffix: true
	enum have_children: [:true, :false, :undefined], _suffix: true

	scope :only_my, ->(user_id) { where(user_id: user_id) }

	acts_as_taggable_on :skills

	#mount_uploader :photo, ResumePhotoUploader
	mount_base64_uploader :photo, ResumePhotoUploader
	mount_uploaders :documents, ResumeDocumentsUploader
end
