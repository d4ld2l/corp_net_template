class ResumeMailer < ApplicationMailer
  def send_email(candidates_ids, emails_to, emails_copy, subject, body, attachs, current_user_id = nil)
    unless candidates_ids.blank?
      resumes = Resume.where(candidate_id: candidates_ids, primary: true)
      resumes.each do |x|
        if x.raw_resume_doc&.path&.present?
          attachments[format_file_name(x.raw_resume_doc&.file, x)] = File.read(x.raw_resume_doc&.file&.current_path)
        elsif x.resume_file&.path&.present?
          attachments[format_file_name(x.resume_file, x)] = File.read(x.resume_file.current_path)
        end
      end
      time = DateTime.current
      Candidate.where(id: candidates_ids).each do |c|
        c.update_history('email_sent', time, nil, nil, Account.find_by_id(current_user_id))
      end
    end
    attachs.each do |x|
      content = x['file']
      attachments[x['name']] = {
          content: Base64.decode64(/(base64,)(.+)/.match(content)&.to_a&.slice(2)),
          mime_type: /^data:([-\w]+\/[-\w\.]+)/.match(content)&.to_a&.slice(1) || ''
      }
    end
    @body = body
    mail(from: ENV['FROM_MAIL'], to: emails_to, cc: emails_copy, subject: subject)
  end

  private

  def format_file_name(file, resume)
    name = resume.full_name&.present? ? resume.full_name : resume.candidate.full_name
    ext = file.file.extension
    "#{name}.#{ext}"
  end
end
