class Api::V0::Resources::AccountSkillsController < Api::ResourceController

  def index
    render json: @collection.as_json
  end

  def confirm
    confirmed_by = current_account
    as = AccountSkill.find(params[:id])
    confirmation = SkillConfirmation.new(account: confirmed_by, account_skill: as)
    if confirmation.save
      render json: { success: true, account_skill: as.reload.as_json(json_resource_inclusion) }
    else
      render json: { success: false, errors: confirmation.errors }
    end
  end

  def unconfirm
    confirmed_by = current_account
    as = AccountSkill.find(params[:id])
    confirmation = SkillConfirmation.find_by(account: confirmed_by, account_skill: as)
    if confirmation&.destroy
      render json: { success: true, account_skill: as.reload.as_json(json_resource_inclusion) }
    else
      render json: { success: false, errors: confirmation&.errors || ['Сущность не найдена'] }
    end
  end

  private

  def json_resource_inclusion
    {
        include: {
            skill: {
                only: [:id, :name]
            },
            skill_confirmations: {
                only: %i[id],
                include: {
                    account: {
                        only: %i[id photo],
                        methods: %i[position_name full_name]
                    }
                }
            }
        }
    }
  end

  def permitted_attributes
    %i[account_id project_id]
  end
end
