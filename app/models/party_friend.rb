class PartyFriend < ApplicationRecord
  belongs_to :party
  belongs_to :friendship
  # belongs_to :friends, class_name: 'User'

  def self.make_multiple_friends(ids, party_id)
    return '' if ids.nil?

    friend = Friendship.where(friend_id: ids)

    friend.each do |friendship|
      # require "pry"; binding.pry
      # friend = Friendship.find_by(id: friendship_id)
      party_friend = PartyFriend.create!(friendship_id: friendship.id, party_id: party_id)
      party_friend.save
    end
  end
end
