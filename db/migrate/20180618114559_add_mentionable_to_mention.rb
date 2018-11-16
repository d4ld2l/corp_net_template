class AddMentionableToMention < ActiveRecord::Migration[5.0]
  def up
    add_reference :mentions, :mentionable, polymorphic: true
  end

  def data
    Mention.all.each do |mention|
      mention.update(mentionable_type: 'Post', mentionable_id: mention.post_id) if mention.post_id.present?
    end
  end

  def down
    remove_reference :mentions, :mentionable, polymorphic: true
  end
end
