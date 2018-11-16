require 'assessment/a360/result/presenter'

module Api::V0::Resources::Assessment
  class SessionsController < Api::ResourceController
    include Api::V0::Resources::Assessment::Sessions
    before_action :set_resource, only: [:update, :show, :destroy, :send_reminders]

    def result
      @resource_instance = resource_collection.includes(
          [
              :skills,
              :participants,
              session_evaluations: [
                  skill_evaluations: [
                      :skill,
                      indicator_evaluations: [
                          :assessment_indicator
                      ]
                  ]
              ]
          ]
      ).find(params[:id])
      p = Assessment::A360::Result::Presenter.new(@resource_instance)
      render json: p.as_json.merge({
          session: @resource_instance.as_json(json_resource_inclusion)
                                   })
    end

    def send_reminders
      unevaluated_accounts_emails = @resource_instance.unevaluated_accounts&.map{|x| x&.email}.uniq
      unevaluated_accounts_emails.each do |r|
        AssessmentSessionsMailer.reminder_notification(
            @resource_instance.account&.full_name,
            @resource_instance.id,
            r
        ).deliver_later
      end
      render json: {success: true, emails: unevaluated_accounts_emails}
    end

    def build
      @resource_instance = resource_collection.includes(
          [
              :skills,
              :participants,
              session_evaluations: [
                  skill_evaluations: [
                      :skill,
                      indicator_evaluations: [
                          :assessment_indicator
                      ]
                  ]
              ]
          ]
      ).find(params[:id])
      send_file @resource_instance.build_report_360.path,
                filename: "#{@resource_instance.name} #{l(Date.today)}.docx", disposition: 'attachment', type: "application/docx"

    end

    private

    def resource_name
      'Assessment::Session'
    end

    def resource_class(variable = nil)
      if variable
        super variable
      else
        @resource_class ||= 'Assessment::Session'.constantize
      end
    end

    def filter_collection
      if params[:status] == 'closed'
        @collection = @collection.available_for_spectators_or_evaluatable(current_account&.id).distinct
      else
        @collection = @collection.available_for(current_account&.id).not_done_by(current_account&.id)
      end
      if params[:status] && resource_class.aasm.states.map(&:name).include?(params[:status]&.to_sym)
        @collection = @collection.where(status:params[:status])
      else
        @collection = @collection.where(status: :in_progress)
      end
    end

    def set_collection
      @collection ||= params[:q] ? search : association_chain
      instance_variable_set("@#{ collection_name }", @collection)
      filter_collection
    end

    def search
      results = resource_class.search(params[:q])
      @search_count = results.results.total
      results.page(page).per(per_page).records.all
    end

    def association_chain
      resource_collection.includes(chain_collection_inclusion).order(updated_at: :desc).page(page).per(per_page)
    end
  end
end
