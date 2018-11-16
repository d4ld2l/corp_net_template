namespace :atest_users do
  desc "Создание и удаление пользователей для автотестов"

  task create: :environment do
    print '  creating atest users '
    ActiveRecord::Base.transaction do
      data = YAML::load_file('lib/tasks/data/atest_user.yml')

      data.each do |attributes|
        user = User.where(email: attributes['email']).first_or_initialize

        profile_attributes = {name: attributes.delete('name'), surname: attributes.delete('surname'), middlename: attributes.delete('middlename')}

        if user.profile.blank?
          user.profile = Profile.create(profile_attributes)
          LegalUnitEmployee.create(legal_unit: LegalUnit.first, profile: user.profile)
        end

        roles = attributes.delete('roles')

        user.update(attributes)

        user.roles << roles.map{|x| Role.find_by(name: x)}.compact unless roles.empty?

        puts "created user with id=#{id} (total: #{ User.count })"
      end
    end
  end

  task delete: :environment do
    ActiveRecord::Base.transaction do
      data = YAML::load_file('db/data/atest_user.yml')

      data.each do |attributes|
        user = User.where(email: attributes['email']).first
        unless user.blank?
          id = user.id
          legal_unit = LegalUnitEmployee.where(profile: user.profile).first

          unless legal_unit.blank?
            legal_unit.destroy
          end

          unless user.profile.blank?
            user.profile.destroy
          end

          user.destroy
        end

        puts "deleted user with id=#{id} (total: #{ User.count })"
      end
    end
  end
end
