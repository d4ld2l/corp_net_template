require 'ldap/server'
require 'ldap_server/ldap_operation'

namespace :ldap_server do
  desc "start"
  task start: :environment do
    puts 'Social simple ldap server'
    ldap_server = LDAP::Server.new(
        :port => 1389,
        :nodelay => true,
        :listen => 10,
        :operation_class => LDAPOperation,
        :operation_args => []
    )
    ldap_server.run_tcpserver
    puts 'LDAP server started'
    ldap_server.join
  end
end