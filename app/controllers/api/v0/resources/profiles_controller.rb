class Api::V0::Resources::ProfilesController < Api::ResourceController
  before_action :authenticate_user!
  include ActionController::ImplicitRender
  def index
    render :index, as: :json, layout: false
  end

  def show
    render json: @resource_instance.as_json(methods: [:managers_chain, :departments_chain, :subordinates_list, :subordinates_count], include: { office:{},
                                               user:{include:{user_projects:{include:{project_role:{}, project:{}}}, role:{}, communities:{}, resumes:{}}},
                                               default_legal_unit_employee:{methods:[:transfers_history], include: {legal_unit:{}, state: {}, contract_type:{}, position:{
                                                  include:{position:{}, department:{include:{manager:{}}}}, office:{}, manager:{}
                                               }}},
                                               legal_unit_employees:{methods:[:transfers_history], include: {legal_unit:{}, state: {}, contract_type:{}, position:{
                                                   include:{position:{}, department:{include:{manager:{}}}}, office:{}, manager:{}
                                               }}}
                                     })
  end

  def me
    @resource_instance = current_user&.profile
    render json: @resource_instance.as_json(methods: [:managers_chain, :departments_chain, :subordinates_list, :subordinates_count], include: { office:{},
                                                user:{include:{user_projects:{include:{project_role:{}, project:{}}}, role:{}, communities:{}, resumes:{}}},
                                                default_legal_unit_employee:{methods:[:transfers_history], include: {legal_unit:{}, state: {}, contract_type:{}, position:{
                                                    include:{position:{}, department:{include:{manager:{}}}}, office:{}, manager:{}
                                                }}},
                                                legal_unit_employees:{methods:[:transfers_history], include: {legal_unit:{}, state: {}, contract_type:{}, position:{
                                                    include:{position:{}, department:{include:{manager:{}}}}, office:{}, manager:{}
                                                }}}
    })
  end

  def create
    if @resource_instance.save
      render json: @resource_instance.as_json(methods: [:managers_chain, :departments_chain, :subordinates_list, :subordinates_count], include: { office:{},
                                                        user:{include:{user_projects:{include:{project_role:{}, project:{}}}, role:{}, communities:{}, resumes:{}}},
                                                        default_legal_unit_employee:{methods:[:transfers_history], include: {legal_unit:{}, state: {}, contract_type:{}, position:{
                                                            include:{position:{}, department:{include:{manager:{}}}}, office:{}, manager:{}
                                                        }}},
                                                        legal_unit_employees:{methods:[:transfers_history], include: {legal_unit:{}, state: {}, contract_type:{}, position:{
                                                            include:{position:{}, department:{include:{manager:{}}}}, office:{}, manager:{}
                                                        }}}
      })
    else
      render json: {success: false, errors: @resource_instance.errors.as_json}
    end
  end

  def update
    if @resource_instance.update_attributes(resource_params)
      render json: @resource_instance.as_json(methods: [:managers_chain, :departments_chain, :subordinates_list, :subordinates_count], include: { office:{},
                                                        user:{include:{user_projects:{include:{project_role:{}, project:{}}}, role:{}, communities:{}, resumes:{}}},
                                                        default_legal_unit_employee:{methods:[:transfers_history], include: {legal_unit:{}, state: {}, contract_type:{}, position:{
                                                            include:{position:{}, department:{include:{manager:{}}}}, office:{}, manager:{}
                                                        }}},
                                                        legal_unit_employees:{methods:[:transfers_history], include: {legal_unit:{}, state: {}, contract_type:{}, position:{
                                                            include:{position:{}, department:{include:{manager:{}}}}, office:{}, manager:{}
                                                        }}}
      })
    else
      render json: { success: false, errors: @resource_instance.errors.as_json }
    end
  end

  private

  def association_chain
    super.order(:surname).not_admins
  end

  def permitted_attributes
    [:surname, :name, :middlename, :email, :photo,
     :birthday, :email_private,
     :phone_number_private, :office_id, :skype, :telegram,
     :vk_url, :fb_url, :linkedin_url]
  end
end
