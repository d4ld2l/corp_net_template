module Admin::Resources::ServicesHelper
  def version_change(v, resource_instance)
    "#{BidStage.find(v.object_changes.split('-')[-2].to_i)&.name} -> #{BidStage.find(v.object_changes.split('-').last.to_i)&.name}"
  rescue
    BidStage.find_by(code: :draft)&.name
  end

  def version_account(v)
    "#{Account.find(v.whodunnit)&.full_name}"
  rescue
    'anonymous'
  end
end
