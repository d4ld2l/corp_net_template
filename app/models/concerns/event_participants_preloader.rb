class EventParticipantsPreloader
  def self.preload(collection)
    preloader = ActiveRecord::Associations::Preloader.new
    preloader.preload(collection.select { |cc| cc.model_name.eql?(Account.name) }, default_legal_unit_employee: [position: %i[position]],
                                                                                        account_emails: [], preferred_email: [])
    preloader.preload(collection.select { |cc| cc.model_name.eql?(Department.name) }, accounts: { default_legal_unit_employee: [position: %i[position]],
                                                                                                       account_emails: [], preferred_email: []})
    preloader.preload(collection.select { |cc| cc.model_name.eql?(MailingList.name) }, accounts: { default_legal_unit_employee: [position: %i[position]],
                                                                                                        account_emails: [], preferred_email: [] })
  end
end
