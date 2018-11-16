STATES_WITH_ALLOWED_BASE = { draft: %i[new],
                             new: %i[in_work rejected],
                             in_work: %i[executed rejected revision_required],
                             revision_required: %i[updated],
                             updated: %i[in_work],
                             executed: [],
                             rejected: [] }.freeze

GROUP = { base: { draft: 'Черновик', updated: 'Обновлена', revision_required: 'Требуется доработка', new: 'Новая',
                  in_work: 'В работе', executed: 'Исполнена', rejected: 'Отклонена' } }.freeze

after :bid_stages_groups do
  print '  creating bid_stages '
  ActiveRecord::Base.transaction do
    GROUP.each do |group_code, attr|
      group = BidStagesGroup.find_by_code(group_code)
      attr.each do |state, name|
        BidStage.where(code: state).first_or_create!(name: name, bid_stages_group_id: group.id,
                                                     initial: state == :draft ? true : false)
      end
    end

    STATES_WITH_ALLOWED_BASE.each do |parent, children|
      current = BidStage.find_by_code(parent)
      children.each do |child|
        allowed = BidStage.find_by_code(child)
        current.allowed_bid_stages.create!(allowed_stage_id: allowed.id, bids_executors:[BidsExecutor.create(user: User.first)], name_for_button: 'Перейти далее', executor: BidsExecutor.create(user: User.first))
      end
    end

    puts " (#{BidStage.count})"
  end
end
