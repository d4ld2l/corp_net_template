# Create a bid report
class Reports::BidBuilder < Reports::BaseBuilder
  private

  def attributes
    {
      '$full_name$' => @resource&.legal_unit&.full_name,
      '$name$'=> @resource&.legal_unit&.name,
      
      '$legal_unit_inn_number$' => @resource&.legal_unit&.inn_number,
      '$legal_unit_kpp_number$' => @resource&.legal_unit&.kpp_number,
      '$legal_unit_org_number$' => @resource&.legal_unit&.ogrn_number,
      '$legal_unit_city$' => @resource&.legal_unit&.city,
      '$legal_unit_director$' => @resource&.legal_unit&.general_director,
      '$legal_unit_administrative_director$' => @resource&.legal_unit&.administrative_director,
      '$legal_unit_general_accountant$' => @resource&.legal_unit&.general_accountant,
      '$legal_unit_general_director$'=> @resource&.legal_unit&.general_director,
      '$legal_unit_legal_address$'=> @resource&.legal_unit&.legal_address,

      '$meeting_information_starts_at$' => (I18n.l(@resource.representation_allowance.meeting_information&.starts_at, format: :long_date) if @resource.representation_allowance.meeting_information&.starts_at.present?),
      '$meeting_information_aim$' => @resource.representation_allowance.meeting_information.aim&.to_s,
      '$meeting_information_aim_capitalized$' => @resource.representation_allowance.meeting_information.aim&.to_s.capitalize,
      '$meeting_information_starts_at_next$' => (I18n.l(@resource.representation_allowance.meeting_information&.starts_at + 1.month, format: :long_date) if @resource.representation_allowance.meeting_information&.starts_at.present?),
      '$meeting_information_starts_at_minus_five$' => (I18n.l(@resource.representation_allowance.meeting_information&.starts_at - 5.days, format: :long_date) if @resource.representation_allowance.meeting_information&.starts_at.present?),
      '$meeting_information_place$' => @resource.representation_allowance.meeting_information.place&.to_s,
      '$meeting_information_amount$' => formatting_amount,
      '$meeting_information_amount_text$' => formatting_amount_text,
      '$meeting_information_amount_round$' => formatting_amount_round,
      '$meeting_information_result$' => @resource.representation_allowance.meeting_information.result,
      '$meeting_information_address$' => @resource.representation_allowance.meeting_information.address,
      
      '$information_about_participant_organization_name$' => @resource.representation_allowance.information_about_participant&.customer&.name,
      '$information_about_participant_customer_name$' => @resource.information_about_participant&.customer&.name,
      '$information_about_participant_counterparties_responsible_name$' => @resource.information_about_participant.responsible_counterparty&.name,
      '$information_about_participant_counterparties_responsible_position$' => @resource.information_about_participant.responsible_counterparty&.position,
      '$information_about_participant_counterparties_name_with_position$' => @resource.information_about_participant.counterparties_for_docx,
      '$information_about_participant_participants_name_with_position$' => @resource.information_about_participant.participants_for_docx,
      '$information_about_participant_counterparties_count$' => @resource.information_about_participant.counterparties.count,
      '$information_about_participant_participants_count$' => @resource.information_about_participant.participants.count,

      '$responsible_name_from_current$' => @resource.information_about_participant.responsible_participant&.account&.full_name_through_dots || @resource.information_about_participant.responsible_participants&.name,
      '$responsible_position_from_current$' => @resource.information_about_participant.responsible_participant&.account&.position_name || @resource.information_about_participant.responsible_participants&.position,

      '$project_charge_code$' => ("Код проекта #{@resource.representation_allowance.information_about_participant&.project&.charge_code}" unless ENV['RAILS_ENV'] == 'tectus' || %w(Тектус.ИТ Мобильные\ профессионалы).include?(@resource.legal_unit&.company&.name)),
      '$current_date$' => I18n.l(DateTime.now, format: :long_date),
      '$bid_manager_full_name$' => @resource.manager&.full_name_through_dots,
      '$assistant_from_current$' => @resource.legal_unit&.assistant&.full_name_through_dots,
    }
  end

  def formatting_amount
    # RuPropisju.rublej_extended_format(@resource.representation_allowance.meeting_information.amount.to_i,
    #                                   :ru,
    #                                   fraction_formatter: '%d',
    #                                   integrals_formatter: '%d',
    #                                   integrals_delimiter: ' ',
    #                                   always_show_fraction: true)
    "#{@resource.representation_allowance.meeting_information.amount.to_i} рублей"
  end

  def formatting_amount_text
    RuPropisju.rublej_extended_format(@resource.representation_allowance.meeting_information.amount.to_i,
                                      :ru,
                                      fraction_formatter: '%d',
                                      integrals_formatter: '%d',
                                      integrals_delimiter: ' ',
                                      always_show_fraction: true)
    # "#{@resource.representation_allowance.meeting_information.amount.to_i} рублей"
  end

  def formatting_amount_round
    amount = @resource.representation_allowance.meeting_information.amount.to_i
    remainder = amount % 1000.to_f
    remainder != 0 ? "#{(amount + 1000 - remainder).to_i}" : "#{amount.to_i}"
  end
end
