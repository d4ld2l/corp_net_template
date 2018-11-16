class CreateDictionariesCompanySeed
  def initialize(company)
    @company = company
  end

  def seed
    ActsAsTenant.with_tenant(@company) do
      [
          {name: "Встреча"},
          {name: "Звонок"},
          {name: "Другое"}
      ].each{ |x| EventType.find_or_create_by(x) }
    end
  end

end
