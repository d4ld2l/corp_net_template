# Create a bid report
class Reports::TeamBuildingBidBuilder

  def initialize(options={})
    @resource = options[:resource]
    @temp_dir = options[:temp_dir] || "#{Rails.root}/tmp"
  end

  def build_report
    require "sablon"
    require "i18n"
    if @resource.team_building_information.approx_cost.nil? || @resource.team_building_information.approx_cost < 100000
      template = Sablon.template(File.open("#{Rails.root}/public/under_100_team_building_sablon.docx"))
    else
      template = Sablon.template(File.open("#{Rails.root}/public/over_100_team_building_sablon.docx"))
    end
    context = {
        legal_unit_name: @resource&.legal_unit.name,
        approx_cost: @resource.team_building_information.approx_cost,
        # legal_unit_address: @resource.legal_unit.legal_address,
        event_date: I18n.l(@resource.team_building_information.event_date.to_date),
        city: @resource.team_building_information.city,
        # manager_name: @resource.manager.full_name,
        # department_name: (@resource.team_building_information.project.department&.name_ru or 'блок не указан'),
        author_full_name: @resource.author.full_name,
        author_position: @resource.author.position_name || 'должность не указана',
        manager_position: @resource.manager.position_name || 'должность не указана',
        # project_code: @resource.team_building_information.project.charge_code,
        # event_address: 'адрес не указан',
        event_date_plus_30_days: I18n.l(@resource.team_building_information.event_date.to_date + 30.days),
        # legal_unit_general_director: @resource.legal_unit.general_director,
        participants: @resource.team_building_information.accounts
    }
    tmp_file = Tempfile.new('teambuilding_report', @temp_dir)
    template.render_to_file tmp_file, context
    tmp_file
  end

  end
