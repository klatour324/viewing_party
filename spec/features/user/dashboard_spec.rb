require 'rails_helper'

RSpec.describe "User Dashboard" do
  describe "Discover Movies Button" do
    it "Redirects user to a discover page when button is clicked" do
      user = User.create(email: "joeb@email.com", password: "test")
      visit root_path

      click_link "Login"

      fill_in :email, with: user.email.upcase
      fill_in :password, with: user.password
      click_button 'Login'

      within(".topnav") do
        expect(page).to have_link("Discover Movies")

        click_link "Discover Movies"
      end

      expect(current_path).to eq(discover_path)
    end
  end

  describe "Viewing Parties Section" do
    it "displays all the details for viewing parties user is invited to" do
      user = User.create(email: "funbucket13@example.com", password: "test")

      visit root_path

      click_link 'Login'

      expect(current_path).to eq(login_path)

      fill_in :email, with: "funbucket13@example.com"
      fill_in :password, with: "test"

      click_button 'Login'

      expect(page).to have_content("Viewing Parties")
    end

    it "shows viewing parties created by user(host) with all the details" do
      user = User.create(email: "funbucket13@example.com", password: "test")

      visit root_path
      click_link 'Login'
      expect(current_path).to eq(login_path)
      fill_in :email, with: "funbucket13@example.com"
      fill_in :password, with: "test"
      click_button 'Login'
      within(".topnav") do
        click_link "Discover Movies"
      end
      fill_in :movie_query, with: "Fight Club"
      click_on("Find Movies")
      click_link "Fight Club"
      click_button("Create Viewing Party for Movie")
      fill_in :duration, with: 900
      fill_in :date, with: DateTime.new(12, 12, 12)
      click_on "Create Party"

      expect(page).to have_content("Viewing Parties")

      expect(page).to have_content("Invited To:")
    end
  end

  describe "Friends Section" do
    describe "happy path" do
      it "has a text field to search friends by email and button to add friends" do
        user1 = User.create(email: "funbucket13@example.com", password: "test")
        user2 = User.create(email: "user@example.com", password: "password")
        # friend1 = user1.friendships.create(user_id: user1.id, friend_id: user2.id)

        visit root_path

        click_link 'Login'

        expect(current_path).to eq(login_path)

        fill_in :email, with: "funbucket13@example.com"
        fill_in :password, with: "test"

        click_button 'Login'

        within("#friends-#{user1.id}") do
          expect(page).to have_content("Friends")
          expect(page).to have_field(:email)
          expect(page).to have_content("You currently have no friends")
          expect(page).to have_button("Add Friend")
        end
      end

      it "can add a friend and see the current list of friends" do
        user1 = User.create(email: "funbucket13@example.com", password: "test")
        user2 = User.create(email: "user@example.com", password: "password")
        # friend1 = user1.friendships.create(user_id: user1.id, friend_id: user2.id)
        visit login_path

        fill_in :email, with: "funbucket13@example.com"
        fill_in :password, with: "test"

        click_button 'Login'

        within("#friends-#{user1.id}") do
          fill_in :email, with: 'user@example.com'

          click_button 'Add Friend'
        end

        expect(current_path).to eq(dashboard_path)
        expect(page).to have_content("You are now following #{user2.email}!")
        expect(page).to have_button("Add Friend")
        expect(page).to_not have_content("You currently have no friends")
      end
    end

    describe "sad path" do
      it "renders an error message if no email exists when searching for" do
        user1 = User.create(email: "funbucket13@example.com", password: "test")
        # user2 = User.create(email: "user@example.com", password: "password")
        # friend1 = user1.friendships.create(user_id: user1.id, friend_id: user2.id)
        visit login_path

        fill_in :email, with: "funbucket13@example.com"
        fill_in :password, with: "test"

        click_button 'Login'

        within("#friends-#{user1.id}") do
          fill_in :email, with: 'bestfriend@example.com'

          click_button 'Add Friend'
        end

        expect(page).to have_content('That user does not exist. Enter a valid email')
      end
    end
  end
end
