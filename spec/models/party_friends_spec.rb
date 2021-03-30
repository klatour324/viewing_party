require 'rails_helper'

describe PartyFriend, type: :model do
  describe "relationships" do
    it { should belong_to :party }
    it { should belong_to :friendship }
  end

  describe "class methods" do
    describe "::make_multiple_friends" do
      it "can make more than one friend for a party" do
        user = User.create(email: 'fun@email.com', password: 'test')
        friend1 = user.friends.create(email: 'a @email.com', password: '123')
        friend2 = user.friends.create(email: 'b@email.com', password: '1234')
        friend3 = user.friends.create(email: 'c@email.com', password: '456')
        movie = Movie.create(api_id: 550)
        party = movie.parties.create(
          movie_id: movie.id,
          movie_title: "FightClub",
          duration: 150,
          date: DateTime.now + 5,
          user_id: user.id
        )
        
        friends = [friend1.id, friend2.id, friend3.id]
        expected = PartyFriend.make_multiple_friends(friends, party.id)
        expect(expected.length).to eq(3)
      end
    end
  end
end
