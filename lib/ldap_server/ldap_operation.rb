require 'ldap/server'

class LDAPOperation < LDAP::Server::Operation
  def simple_bind(version, dn, password)
    Rails.logger.info 'bind user'
    if version != 3
      raise LDAP::ResultError::ProtocolError, "version 3 only"
    end
    if dn == 'chat.server@social.ru' # Chat server auth
      return
    end
    return if dn.nil? || dn.empty?
    account_email = /uid=(.+)/.match(dn)[0].split('=').last.gsub(',', '')
    Rails.logger.info account_email
    account = Account.find_by email: account_email
    Rails.logger.info account
    raise LDAP::ResultError::InvalidCredentials unless account
    raise LDAP::ResultError::InvalidCredentials unless account.valid_password?(password)
  end

  def search(basedn, scope, deref, filter)
    Rails.logger.info 'search user by:'
    Rails.logger.info filter[3].last
    account = Account.find_by email: filter[3].last
    raise LDAP::ResultError::UnwillingToPerform unless account
    send_SearchResultEntry "uid=#{account.email}", {
      'mail' => [account.email],
      'username' => [account.full_name.delete(' ').empty? ? account.email.split('@').first : account.full_name],
      'cn' => [account.email.split('@').first],
    }
  end
end
