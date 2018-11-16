class Api::V0::Resources::DictionariesController < Api::ResourceController
  def index
    if params[:dictionary_name] == 'professional_area'
      render json: @collection.as_json(include: :professional_specializations)
    elsif params[:dictionary_name] == 'vacancy_stage_group'
      render json: @collection.includes(:candidates).as_json(methods: :candidates_count)
    elsif params[:dictionary_name] == 'department_names'
      render json: @collection.distinct.pluck(:name_ru) # as_json(only: %i[id name_ru])
    elsif params[:dictionary_name] == 'accounts_city'
      all_cities = Account.distinct.pluck(:city).reject { |c| c.nil? || c.empty? }
      render json: all_cities
    else
      render json: @collection.as_json
    end
  end

  private

  DICTIONARIES = %w[accounts_city department department_names office bonus_reason language language_level professional_area professional_specialization education_level vacancy_stage_group news_category tag contract_type event_type resume_source skill position candidate_skill structure_unit employee_state].freeze

  def collection_name
    if DICTIONARIES.include?(params[:dictionary_name])
      @collection_name ||= params[:dictionary_name]
    else
      raise ActionController::RoutingError, 'Not Found'
    end
  end

  def association_chain
    if params[:dictionary_name] == 'tag'
      res = ActsAsTaggableOn::Tag.all.where('taggings_count > 0')
      if params[:entity]
        res = res.joins(:taggings).where('taggings.taggable_type=?', params[:entity]&.classify).distinct
      end
      if params[:context]
        res = res.joins(:taggings).where('taggings.context ilike ?', params[:context]).distinct
      end
      res
    elsif params[:dictionary_name] == 'structure_unit'
      LegalUnitEmployee.all.map(&:structure_unit)&.compact&.uniq&.as_json
    elsif params[:dictionary_name] == 'employee_state'
      LegalUnitEmployeeState.all.map(&:state)&.compact&.uniq&.as_json

    elsif params[:dictionary_name] == 'department_names'
      if params[:legal_unit_ids].present?
        legal_unit_ids = params[:legal_unit_ids].split(',')
        Department.where(legal_unit_id: legal_unit_ids)
      else
        Department.all
      end

    elsif params[:dictionary_name] == 'accounts_city'
      nil

    elsif params[:dictionary_name] == 'candidate_skills'
      ActsAsTaggableOn::Tag.all.joins(:taggings).where(taggings: { taggable_type: 'Resume', context: 'skills' }).where('taggings_count > 0')
    else
      resource_collection.all
    end
  end

  def permitted_attributes
    %i[name legal_unit_ids]
  end

  def search
    if %w[tag candidate_skills].include? params[:dictionary_name]
      association_chain.where('name like ?', "#{params[:q]}%").distinct
    else
      super
    end
  end
end
