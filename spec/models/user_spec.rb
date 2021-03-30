require 'rails_helper'

describe User, type: :model do
  describe "validations" do
    it {should validate_presence_of(:email)}
    it {should validate_uniqueness_of(:email)}
    it {should validate_presence_of(:password)}
  end

  describe "relationships" do
    it { should have_many :parties }
    it { should have_many :friendships }
    it { should have_many(:friends).through(:friendships) }
  end

  describe 'instance methods' do
    describe "#invites" do
      it "can invite friends to the viewing party" do
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

        # party.party_friends.create(friendship_id: friend1.id)
        # party.party_friends.create(friendship_id: friend2.id)
        # party.party_friends.create(friendship_id: friend3.id)
        #
        # expect(user.invites).to eq([friend1, friend2, friend3])

      end
    end
  end

  describe "class method" do
    describe "::sanitize_email" do
      it "returns email in lowercase format" do
        user = User.create(email:'FUNbuCKET@email.com', password: 'test')

        expect(user.email.downcase).to eq('funbucket@email.com')
      end
    end
  end
end
