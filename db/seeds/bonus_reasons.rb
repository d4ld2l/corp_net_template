class BonusReasonsSeed
  def seed
    %w[Проектные\ расходы Фитнес Связь Доплата\ за\ командировку Бонус\ за\ рекомендацию Бонус\ (сотруднику\ за\ период) Другое].map { |x| { name: x } }.each do |br|
      BonusReason.find_or_create_by!(br)
    end
  end
end
