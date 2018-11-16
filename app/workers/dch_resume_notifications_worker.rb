class DchResumeNotificationsWorker
  include Sidekiq::Worker

  def perform(candidate_ids, emails_to, emails_copy, body, attachs)
    # отправлять резюме кандидатов
    # unless candidates_ids.blank?
    #   resumes = Resume.where(candidate_id: candidates_ids, primary: true)
    #   resumes.each do |x|
    #     if x.raw_resume_doc&.present?
    #       x.raw_resume_doc&.file
    #     elsif x.resume_file&.present?
    #       x.resume_file
    #     end
    #   end
    # end

    # отправлять attachs
    users = Account.where(email: [emails_to, emails_copy].flatten).pluck(:uid)
    @body = parse_children(Nokogiri::HTML(body).children)
    users.each{|uid| ExternalIntegrations::DchApi.new(body(uid)).send_notification }
  end

  private

  def body uid
    { uid: uid, message: @body }
  end

  def parse_children elem
    if elem.class == Nokogiri::XML::Text
      return elem.text.squeeze
    end
    url = ""

    if elem.class == Nokogiri::XML::Element && elem.name == 'a'
      url = " " + elem.attributes["href"]
    end
    elem.children.map{|c| parse_children(c)}.join + url
  end

end


