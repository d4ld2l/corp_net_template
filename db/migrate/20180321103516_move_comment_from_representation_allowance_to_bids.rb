class MoveCommentFromRepresentationAllowanceToBids < ActiveRecord::Migration[5.0]
  def change
    add_column :bids, :creator_comment, :string
  end

  def data
    RepresentationAllowance.all.each do |r|
      b = r.bid
      if b
        b.creator_comment = r&.meeting_information&.comment
        b.save
      end
    end
  end
end
