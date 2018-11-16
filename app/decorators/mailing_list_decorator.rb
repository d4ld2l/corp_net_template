class MailingListDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end
  def accounts_array
    accounts.map {|p|
      {
          id: p.account_id,
          account_id: p.id,
          full_name: p.full_name,
          email: p.email,
          # email_private: p.email_private,
          photo: p.photo,
          email_work: p.default_legal_unit_employee&.email_work,
          email_corporate: p.default_legal_unit_employee&.email_corporate,
          position_name: p.default_legal_unit_employee&.legal_unit_employee_position&.position&.name_ru,
          departments_chain: p.departments_chain
      }
    }
  end

end
