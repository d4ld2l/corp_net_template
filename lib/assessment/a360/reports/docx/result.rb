module Assessment::A360::Reports::Docx
  class Result

    def initialize(options={})
      @resource = options[:resource]
      @temp_dir = options[:temp_dir] || "#{Rails.root}/tmp"
      @charts_creator = Assessment::A360::Reports::Docx::Charts.new
    end

    def build_report(session)
      require "sablon"
      require "i18n"

      hash_for_session = Assessment::A360::Result::Presenter.new(session).as_json
      images_hash = @charts_creator.make_pics_for_session(hash_for_session, session.id)

      template = Sablon.template(File.open("#{Rails.root}/public/report360_sablon.docx"))

      poll_dates_string = "#{I18n.l(session.created_at.to_date)}"
      poll_dates_string += ", #{I18n.l(session.due_date.to_date)}" if session.due_date.present?

      context = {
          employee_fio: session.account.full_name,
          employee_department: session.account.default_legal_unit_employee&.department_name || "Не указано",
          employee_position: session.account.default_legal_unit_employee&.position&.position&.name_ru || "Не указана",
          poll_dates: poll_dates_string,
          competences: get_competences(hash_for_session), # [{skill_name: 'Играть в суприм коммандер', indicators_names: 'ну там короч масс экстракторы выход в Т2 тыры пыры'}],
          mean_total_graph: Sablon.content(:image, images_hash[:avgs]),
          ma: form_ma_hash(session),
          general_conclusion: (session.conclusion.strip_html_tags) || "Вывод не указан",
          self_and_others_graphs: get_sablon_images_array_from_paths(images_hash[:categories]),
          si_detalization: get_si_detalization(hash_for_session, images_hash),
          comments: form_comments_list(hash_for_session)
      }

      tmp_file = Tempfile.new(['report360', '.docx'], @temp_dir)
      template.render_to_file tmp_file, context
      @charts_creator.cleanup_temporary_charts
      tmp_file
    end

    private

    def get_si_detalization(h, imgs_hash)
      si_det = []
      h[:skills].each_with_index do |skills_hash, s_i|
        s_hash = {
            name: skills_hash["name"],
            ind_pic: Sablon.content(:image, imgs_hash[:indicators][s_i]),
            sself: skills_hash[:avg_score_self] || 0,
            non_self: skills_hash[:avg_score_not_self] || 0,
            manager: skills_hash[:avg_score_manager] || 0,
            subordinate: skills_hash[:avg_score_subordinate] || 0,
            associate: skills_hash[:avg_score_associate] || 0,
            indicators: []
        }

        # The following code is too terrible for you to see. Believe me.
        vals_hash = {}
        skills_hash[:indicators][:common].each do |ind|
          vals_hash.merge!(ind[:name] => [])
        end
        vals_hash.each do |k, v|

          [:self, :not_self, :manager, :subordinate, :associate].each_with_index do |category, category_index|
            skills_hash[:indicators][category].each do |ind|
              v << (ind[:avg_score]) || 0 if ind[:name] == k
            end
            v << 0 if v.length == category_index
          end
        end

        vals_hash.each do |k, v|
          s_hash[:indicators] << {
              name: k,
              sself: (v[0]) || 0,
              non_self: (v[1]) || 0,
              manager: (v[2]) || 0,
              subordinate: (v[3]) || 0,
              associate: (v[4]) || 0,
          }
        end

        si_det << s_hash
      end
      si_det
    end

    def get_competences(h)
      arr = []

      h[:skills].each do |sk|
        skill_name = sk["name"]
        indicators_names = ""
        sk[:indicators][:common].each do |ind|
          indicators_names += "#{ind[:name]}; "
        end
        indicators_names.chomp!('; ')
        arr << {skill_name: skill_name, indicators_names: indicators_names}
      end

      arr
    end

    def form_ma_hash(session)
      ma = {
          blind_spots: [],
          strong: [],
          improvement: [],
          hidden: []
      }
      ma[:strong] << session.obvious_fortes.strip_html_tags
      ma[:hidden] << session.hidden_fortes.strip_html_tags
      ma[:improvement] << session.growth_direction.strip_html_tags
      ma[:blind_spots] << session.blind_spots.strip_html_tags
      # h[:skills].each do |skill|
      #   self_score = (skill[:avg_score_self] || 0)
      #   non_self_score = (skill[:avg_score_not_self] || 0)
      #   # Явные сильные стороны (Самооценка ˃4; Оценка окружающих ˃4)
      #   if self_score > 4 && non_self_score > 4
      #     ma[:strong] << skill["name"]
      #   end
      #   # Скрытые сильные стороны (Самооценка ≤ 4; Оценка окружающих ˃ 4)
      #   if self_score <= 4 && non_self_score > 4
      #     ma[:hidden] << skill["name"]
      #   end
      #   # Зоны развития (Самооценка ≤4; Оценка окружающих ≤4)
      #   if self_score <= 4 && non_self_score <= 4
      #     ma[:improvement] << skill["name"]
      #   end
      #   # «Слепое пятно» (Самооценка ˃4; Оценка окружающих ≤4)
      #   if self_score > 4 && non_self_score <= 4
      #     ma[:blind_spots] << skill["name"]
      #   end
      # end
      ma
    end

    def get_sablon_images_array_from_paths(paths)
      arr = []
      paths.each do |p|
        arr << Sablon.content(:image, p)
      end
      arr
    end

    def form_comments_list(h)
      comments = []
      h[:skills].each do |skill|
        comments << skill[:comments]
      end
      comments = comments.flatten
      comments << "Комментарии отсутствуют." if comments.blank?
      comments
    end

  end

end
