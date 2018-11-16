# Info360Parser for parse info about candidate
class Info360::Parser
  include Sidekiq::Worker
  sidekiq_options queue: 'info360', retry: true, backtrace: true

  def perform(candidate_id)
    info360 = Info360.find_or_create_by(candidate_id: candidate_id)
    candidate = Candidate.find(candidate_id)
    parse_info_github(info360, candidate)
  end

  def parse_info_github(info360, candidate)
    info360_source_github = Info360SourceGithub.find_or_initialize_by(info360: info360)
    # search/parse github
    candidate_email = candidate&.resume&.resume_contacts&.find_by(contact_type: 'email', preferred: true)&.value
    candidate_full_name = candidate.full_name
    github_link = candidate.resume.additional_contacts.where(type: 'github').first&.link
    if github_link.present?
      url = github_link.gsub('github.com', 'api.github.com/users')
      res = Net:: HTTP.get_response URI(url)
      github_info = JSON.parse(res.body)
      info360_source_github.account_url = github_info['html_url']
    elsif candidate_email.present?
      res = search_github_account(candidate_email)
      unless JSON.parse(res.body)['items'].present?
        res = search_github_account(candidate_email.split('@').first)
        unless JSON.parse(res.body)['items'].present?
          res = search_github_account(candidate_full_name)
        end
      end
    else
      res = search_github_account(candidate_full_name)
    end
    if JSON.parse(res.body)['items'].present? && !github_link.present?
      github_info = JSON.parse(res.body)['items'].first
      info360_source_github.account_url = github_info['html_url']
    end
    # parse data from GitHub info
    if github_info
    # repositories
      repos_info = Net::HTTP.get_response URI(github_info['repos_url'])
      repos = JSON.parse(repos_info.body)
      repos.each do |repo|
        repository = Info360SourceGithubRepository.create(url: repo['html_url'], fork: repo['fork'])
        info360_source_github.info360_source_github_repositories << repository
      end
    # base info
      info360_source_github.hire_able = github_info['hireable']
      events_info = Net::HTTP.get_response URI(info360_source_github.account_url.gsub('github.com', 'api.github.com/users') + '/events')
      event = JSON.parse(events_info.body)&.first
      info360_source_github.last_events_date = DateTime.parse(event['created_at']) if event
    # save info
      info360_source_github.save
    end
  end

  def search_github_account(search_params)
    url = 'https://api.github.com/search/users?q=' + search_params
    Net::HTTP.get_response URI.parse URI.encode(url)
  end
end
