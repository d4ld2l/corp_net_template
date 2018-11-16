class AdditionalContact < ApplicationRecord
  AdditionalContact.inheritance_column = 'itype'

  enum type: %i[vk linkedin github facebook moi_krug freelance livejournal personal other]

  belongs_to :resume, touch: true
end
