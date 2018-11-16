module Assessment::A360::Reports::Docx
  class Charts
    require 'gruff'

    def initialize(options={})
      @path_for_pics = ''
    end

    def make_pics_for_session(session_hash, session_id)
      # skills = session_hash[:skills]
      `mkdir -p tmp/pngs/session#{session_id}`
      @path_for_pics = "tmp/pngs/session#{session_id}"
      {
        avgs: skills_averages_by_categories(session_hash),
        categories: categories_comparison(session_hash),
        indicators: indicators_comparison(session_hash)
      }
    end

    def cleanup_temporary_charts
      `rm -r #{@path_for_pics}`
    end

    private

    SHR_THEME = {
        :colors => [
            '#0070c0',  # blue
            '#31b395',  # teal
            '#92d050',  # green
            '#ed671b',  # red
            '#ffc000',  # orange
            '#999999',  # light grey
            'black'
        ],
        :marker_color => 'black',
        :font_color => 'black',
        :background_colors => %w(#ffffff #ffffff)
    }

    def skills_averages_by_categories(session_hash)
      skills = session_hash[:skills]

      g = Gruff::Bar.new
      g.title = '' # не ошибка
      g.theme = SHR_THEME 
      g.show_labels_for_bar_values =true

      labels_hash = {} # skills names
      skills.each_with_index {|s, i| labels_hash.merge!(i => s["name"]) }
      g.labels = labels_hash


      avg_score_self = []
      avg_score_manager = []
      avg_score_associate = []
      avg_score_subordinate = []
      skills.each do |s|
        avg_score_self << (s[:avg_score_self] || 0)
        avg_score_manager << (s[:avg_score_manager] || 0)
        avg_score_associate << (s[:avg_score_associate] || 0)
        avg_score_subordinate << (s[:avg_score_subordinate] || 0)
      end

      g.data "Самооценка", avg_score_self
      g.data "Руководители", avg_score_manager
      g.data "Подчинённые", avg_score_subordinate
      g.data "Коллеги", avg_score_associate

      g.minimum_value =0
      g.maximum_value = 6
      g.marker_font_size = 16
      g.spacing_factor = 0.2

      file_path = "#{@path_for_pics}/skills_avgs_by_categories.png"
      g.write(file_path)
      file_path
    end

    def categories_comparison(session_hash)
      skills = session_hash[:skills]
      labels_hash = {} # skills names
      skills.each_with_index {|s, i| labels_hash.merge!(i => s["name"]) }

      graphs = []
      file_paths = []

      5.times {graphs << Gruff::Bar.new}

      graphs.each do |g|
        g.title = '' # не ошибка
        g.theme = SHR_THEME 
        g.labels = labels_hash
        g.show_labels_for_bar_values =true
      end

      avg_score_self = []
      avg_score_not_self = []
      avg_score_manager = []
      avg_score_associate = []
      avg_score_subordinate = []
      skills.each do |s|
        avg_score_self << (s[:avg_score_self] || 0)
        avg_score_not_self << (s[:avg_score_not_self] || 0)
        avg_score_manager << (s[:avg_score_manager] || 0)
        avg_score_associate << (s[:avg_score_associate] || 0)
        avg_score_subordinate << (s[:avg_score_subordinate] || 0)
      end

      graphs[0].data "Общий результат (без самооценки)", avg_score_not_self

      graphs[1].data "Общий результат (без самооценки)", avg_score_not_self
      graphs[1].data "Самооценка", avg_score_self

      graphs[2].data "Самооценка", avg_score_self
      graphs[2].data "Руководители", avg_score_manager

      graphs[3].data "Самооценка", avg_score_self
      graphs[3].data "Подчинённые", avg_score_subordinate

      graphs[4].data "Самооценка", avg_score_self
      graphs[4].data "Коллеги", avg_score_associate

      # Yup, this should be called AFTER the data assignment.
      graphs.each_with_index do |g, i|
        g.minimum_value =0
        g.maximum_value = 6
        g.marker_font_size = 14
        g.spacing_factor = 0.2
        # g.legend_at_bottom = true
        file_path = "#{@path_for_pics}/categories_comparison_#{i}.png"
        g.write(file_path)
        file_paths << file_path
      end
      file_paths
    end

    def indicators_comparison(session_hash)
      skills = session_hash[:skills]
      file_paths = []

      skills.each_with_index do |current_skill, skill_index|
        g = Gruff::Bar.new
        g.title = '' # не ошибка
        g.theme = SHR_THEME 
        g.show_labels_for_bar_values = true
        # current_skill[:indicators][:common].map {|i| i[:name]}.each_with_index {|s, i| labels_hash.merge!(i => s)}
        g.labels = {0 => 'Самооценка', 1 => 'Руководители', 2 => 'Подчинённые', 3 => 'Коллеги', }

        vals_hash = {}

        current_skill[:indicators][:common].each do |ind|
          vals_hash.merge!(ind[:name] => [])
        end

        vals_hash.each do |k, v|

          [:self, :manager, :subordinate, :associate].each_with_index do |category, category_index|
            current_skill[:indicators][category].each do |ind|
              v << (ind[:avg_score]) || 0 if ind[:name] == k
            end
            v << 0 if v.length == category_index
          end

          g.data(k, v)
        end

        g.minimum_value =0
        g.maximum_value = 6
        g.legend_font_size = 12
        g.spacing_factor = 0.2
        # g.legend_margin = 125
        # g.legend_at_bottom = true

        file_path = "#{@path_for_pics}/indicators_comparison_#{skill_index}.png"
        g.write(file_path)
        file_paths << file_path
      end
      file_paths
    end

  end
end
