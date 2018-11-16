module Admin
  module Resources
    module Assessment
      require 'assessment/a360/result/presenter'
      require 'assessment/a360/reports/xlsx/sessions'

      class SessionsController < Admin::ResourceController
        before_action :set_collection, only: [:index, :as_xlsx]
        include Paginatable
        before_action :set_resource, only: [:edit, :update, :show, :destroy, :build, :change_state, :send_reminders]
        before_action :set_locals
        before_action :set_gon_variables
        before_action :set_result, only: [:show]

        def create
          @resource_instance.created_by = current_account
          super
        end

        def as_xlsx
          file = ::Assessment::A360::Reports::Xlsx::Sessions.new(@collection).build
          send_file file, filename: "Оценочные сессии #{l(Date.today)}.xlsx", type: "application/xlsx"
        end

        def build
          file = @resource_instance.build_report_360
          send_file file, filename: "#{@resource_instance.name} #{l(Date.today)}.docx", type: "application/xlsx"
        end

        def change_state
          if @resource_instance.send("may_to_#{params[:state]}?")
            @resource_instance.send("to_#{params[:state]}!")
            redirect_back fallback_location: @resource_instance, notice: 'Успешно переведено'
          else
            redirect_to @resource_instance, errors: 'Невозможно перевести в данный статус'
          end
        end

        def send_reminders
          @resource_instance.unevaluated_accounts&.map{|x| x&.email}.uniq.each do |r|
            AssessmentSessionsMailer.reminder_notification(
                @resource_instance.account&.full_name,
                @resource_instance.id,
                r
            ).deliver_later
          end
          redirect_back fallback_location: @resource_instance, notice: 'Успешно отправлено'
        end

        private

        def set_result
          s = resource_class.includes(
              [
                  :skills,
                  participants:[:account],
                  session_evaluations: [
                      skill_evaluations: [
                          :skill,
                          indicator_evaluations: [
                              :assessment_indicator
                          ]
                      ]
                  ]
              ]
          ).where(id: params[:id]).first
          @result = ::Assessment::A360::Result::Presenter.new(s).as_json
          gon.summary_chart = {
              labels: @result[:skills].map{|x| x['name']},
              datasets: [
                  {
                      label: 'Общая',
                      data: @result[:skills].map{|x| x[:avg_score_common]},
                      backgroundColor: "rgba(220,0,0,0.6)"
                  },
                  {
                      label: 'Самооценка',
                      data: @result[:skills].map{|x| x[:avg_score_self]},
                      backgroundColor: "rgba(0,220,0,0.6)"
                  },
                  {
                      label: 'Все оценки, кроме самостоятельной',
                      data: @result[:skills].map{|x| x[:avg_score_not_self]},
                      backgroundColor: "rgba(0,0,220,0.6)"
                  },
                  {
                      label: 'Оценка руководителей',
                      data: @result[:skills].map{|x| x[:avg_score_manager]},
                      backgroundColor: "rgba(220,220,0,0.6)"
                  },
                  {
                      label: 'Оценка коллег',
                      data: @result[:skills].map{|x| x[:avg_score_associate]},
                      backgroundColor: "rgba(220,0,220,0.6)"
                  },
                  {
                      label: 'Оценка подчиненных',
                      data: @result[:skills].map{|x| x[:avg_score_subordinate]},
                      backgroundColor: "rgba(0,220,220,0.6)"
                  }
              ]
          }
          skills_chart = {}
          @result[:skills].each do |sc|
            datasets = [
                {
                    label: 'Общая',
                    data: sc[:indicators][:common].map{|x| x[:avg_score]},
                    backgroundColor: "rgba(220,0,0,0.6)"
                },
                {
                    label: 'Самооценка',
                    data: sc[:indicators][:self].map{|x| x[:avg_score]},
                    backgroundColor: "rgba(0,220,0,0.6)"
                },
                {
                    label: 'Все оценки, кроме самостоятельной',
                    data: sc[:indicators][:not_self].map{|x| x[:avg_score]},
                    backgroundColor: "rgba(0,0,220,0.6)"
                },
                {
                    label: 'Оценка руководителей',
                    data: sc[:indicators][:manager].map{|x| x[:avg_score]},
                    backgroundColor: "rgba(220,220,0,0.6)"
                },
                {
                    label: 'Оценка коллег',
                    data: sc[:indicators][:associate].map{|x| x[:avg_score]},
                    backgroundColor: "rgba(220,0,220,0.6)"
                },
                {
                    label: 'Оценка подчиненных',
                    data: sc[:indicators][:subordinate].map{|x| x[:avg_score]},
                    backgroundColor: "rgba(0,220,220,0.6)"
                }
            ]
            skills_chart[sc['id']] = {
                lables: sc[:indicators][:common].map{|i| i[:name].split(' ').in_groups_of(3).map{|x| x.join(' ')}},
                datasets: datasets
            }
          end
          gon.skill_charts = skills_chart
        end

        def search
          @blank_stripped_params = params.to_unsafe_h.strip_blanks
          results = resource_class.search(@blank_stripped_params.dig("q", "q"), @blank_stripped_params&.dig("q"))
          @search_count = results.results.total
          results.per(1000).records
        end

        def set_gon_variables
          gon.project_roles_skills = @project_roles.includes(:skills).as_json({
                                                                                  only: [:id, :name],
                                                                                  include: { skills: { only: [:id] } }
                                                                              })
          gon.dynamic_skills_insertion_enabled = @resource_instance.present? && @resource_instance.status == 'created'
          gon.skills = Skill.all.joins(:indicators).distinct.as_json({
              only: [:id],
              include: {
                  indicators:{ only: [:name] }
              }
          })
          # gon.stored_session_skills = @resource_instance.session_skills.as_json(only:[:id, :skill_id])
        end

        def set_locals
          @skills = Skill.all.joins(:indicators).order(:name, :indicators_count).distinct
          @accounts = Account.all.order(:surname).not_blocked.not_admins
          @project_roles = ::Assessment::ProjectRole.order(:name).all
          @evaluations = @resource_instance&.session_evaluations
        end

        def permitted_attributes
          [
              :name, :account_id, :kind, :rating_scale, :project_role_id,
              :status, :description, :final_step_text, :logo, :color, :due_date,
              :obvious_fortes, :hidden_fortes, :growth_direction, :blind_spots, :conclusion,
              participants_attributes: [
                  :id, :kind, :account_id, :_destroy
              ],
              manager_participants_attributes: [
                  :id, :kind, :account_id, :_destroy
              ],
              associate_participants_attributes: [
                  :id, :kind, :account_id, :_destroy
              ],
              subordinate_participants_attributes: [
                  :id, :kind, :account_id, :_destroy
              ],
              session_skills_attributes: [
                :id, :skill_id, :position, :_destroy
              ],
              session_evaluations_attributes:[
                  :id,
                  skill_evaluations_attributes:[
                    :id, :comment
                  ]
              ],
              spectators_attributes: [
                  :id, :account_id, :_destroy
              ],
          ]
        end

        def resource_class
          'Assessment::Session'.constantize
        end

        def resource_collection
          'Assessment::Session'.constantize
        end

        def collection_name
          'sessions'
        end
      end
    end
  end
end
