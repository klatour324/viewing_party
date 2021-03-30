class PartyFriend < ApplicationRecord
  belongs_to :party
  belongs_to :friendship

  def self.make_multiple_friends(ids, party_id)
    return '' if ids.nil?

    friend = Friendship.where(friend_id: ids)

    friend.each do |friendship|
      party_friend = PartyFriend.create!(friendship_id: friendship.id, party_id: party_id)
      party_friend.save
    end
  end
end
