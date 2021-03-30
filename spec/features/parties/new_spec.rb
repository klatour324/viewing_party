require 'rails_helper'

RSpec.describe "As an authenticated user" do
  describe "when I navigate to create a new party from Fight Club" do
    it "has a form to fill out attributes" do
      VCR.use_cassette('viewing_party_path') do
        user = User.create(email: "joeb@email.com", password: "test")
        visit root_path
        click_link "Login"
        fill_in :email, with: user.email.upcase
        fill_in :password, with: user.password
        click_button 'Login'
        within(".topnav") do
          click_link "Discover Movies"
        end

        fill_in :movie_query, with: "Fight Club"
        click_on("Find Movies")
        click_link "Fight Club"
        click_button("Create Viewing Party for Movie")

        expect(page).to have_content("Movie Title: Fight Club")
        expect(page).to have_content("Date and Time of Event:")
        expect(page).to have_content("Duration:")
      end
    end
    it "creates a party object when the form is submitted" do
      VCR.use_cassette('create_new_viewing_party_path') do
        user = User.create(email: "joeb@email.com", password: "test")
        visit root_path
        click_link "Login"
        fill_in :email, with: user.email.upcase
        fill_in :password, with: user.password
        click_button 'Login'
        within(".topnav") do
          click_link "Discover Movies"
        end

        fill_in :movie_query, with: "Fight Club"
        click_on("Find Movies")
        click_link "Fight Club"

        click_button("Create Viewing Party for Movie")


        fill_in :duration, with: 900
        fill_in :date, with: (DateTime.now + 5)
        click_on "Create Party"

        expect(current_path).to eq(dashboard_path)
        expect(Party.exists?(user_id: user.id, movie_title: "Fight Club")).to eq(true)
      end
    end
    it "creates sends an error message if a date is not filled out" do
      VCR.use_cassette('sad_date_viewing_party_error_path') do
        user = User.create(email: "joeb@email.com", password: "test")
        visit root_path
        click_link "Login"
        fill_in :email, with: user.email.upcase
        fill_in :password, with: user.password
        click_button 'Login'
        within(".topnav") do
          click_link "Discover Movies"
        end

        fill_in :movie_query, with: "Fight Club"
        click_on("Find Movies")
        click_link "Fight Club"

        click_button("Create Viewing Party for Movie")


        fill_in :date, with: ""
        click_on "Create Party"

        expect(page).to have_content("Date and duration must be selected")
      end
    end
    it "creates sends an error message if a date is not filled out" do
      VCR.use_cassette('sad_duration_viewing_party_error_path') do
        user = User.create(email: "joeb@email.com", password: "test")
        visit root_path
        click_link "Login"
        fill_in :email, with: user.email.upcase
        fill_in :password, with: user.password
        click_button 'Login'
        within(".topnav") do
          click_link "Discover Movies"
        end

        fill_in :movie_query, with: "Fight Club"
        click_on("Find Movies")
        click_link "Fight Club"

        click_button("Create Viewing Party for Movie")


        fill_in :duration, with: ""
        click_on "Create Party"

        expect(page).to have_content("Date and duration must be selected")
      end
    end

    it 'Has checkboxs to invite each new friend to a viewing party' do
      VCR.use_cassette('sad_duration_viewing_party_error_path') do
        user = User.create(email: "joeb@email.com", password: "test")
        user2 = user.friends.create(email: "a@a.com", password: "test")
        user3 = user.friends.create(email: "b@b.com", password: "test")
        user4 = user.friends.create(email: "c@c.com", password: "test")

        visit root_path
        click_link "Login"
        fill_in :email, with: user.email.upcase
        fill_in :password, with: user.password
        click_button 'Login'
        within(".topnav") do
          click_link "Discover Movies"
        end

        fill_in :movie_query, with: "Fight Club"
        click_on("Find Movies")
        click_link "Fight Club"

        # expect(current_path).to eq(movie_path())
        click_button("Create Viewing Party for Movie")
        expect(current_path).to eq(new_party_path)

        find(:css, "#friends_#{user2.id}").set(true)

        find(:css, "#friends_#{user3.id}").set(true)

        find(:css, "#friends_#{user4.id}").set(true)
      end
    end

    it 'can fill out a form and check the boxes next to each friends to add to a new viewing party' do
      VCR.use_cassette('invite_friends_path') do
        user = User.create(email: "joeb@email.com", password: "test")
        user2 = user.friends.create(email: "a@a.com", password: "test")
        user3 = user.friends.create(email: "b@b.com", password: "test")
        user4 = user.friends.create(email: "c@c.com", password: "test")

        visit root_path
        click_link "Login"
        fill_in :email, with: user.email.upcase
        fill_in :password, with: user.password
        click_button 'Login'

        within(".topnav") do
          click_link "Discover Movies"
        end

        fill_in :movie_query, with: "Fight Club"
        click_on("Find Movies")
        click_link "Fight Club"

        # expect(current_path).to eq(movie_path())
        click_button("Create Viewing Party for Movie")
        expect(current_path).to eq(new_party_path)

        expect(page).to have_field(:date)
        expect(page).to have_field(:duration)

        fill_in 'date', with: (DateTime.now + 5)
        fill_in 'duration', with: 140

        find(:css, "#friends_#{user2.id}").set(true)

        find(:css, "#friends_#{user3.id}").set(true)

        find(:css, "#friends_#{user4.id}").set(true)
        click_button 'Create Party'

        expect(current_path).to eq(dashboard_path)
        expect(page).to have_content("140 minutes")
        # expect(page).to have_content("Hosting: #{user.email}")

        within("#friends-#{user.id}") do
          expect(page).to have_content(user2.email)
          expect(page).to have_content(user3.email)
          expect(page).to have_content(user4.email)
        end
      end
    end

    it "can create a party without friends" do
      VCR.use_cassette('invite_friends_path') do
        user = User.create(email: "joeb@email.com", password: "test")
        user2 = user.friends.create(email: "a@a.com", password: "test")
        user3 = user.friends.create(email: "b@b.com", password: "test")
        user4 = user.friends.create(email: "c@c.com", password: "test")

        visit root_path
        click_link "Login"
        fill_in :email, with: user.email.upcase
        fill_in :password, with: user.password
        click_button 'Login'

        within(".topnav") do
          click_link "Discover Movies"
        end

        fill_in :movie_query, with: "Fight Club"
        click_on("Find Movies")
        click_link "Fight Club"

        click_button("Create Viewing Party for Movie")
        expect(current_path).to eq(new_party_path)

        expect(page).to have_field(:date)
        expect(page).to have_field(:duration)

        fill_in 'date', with:(DateTime.now + 5)
        fill_in 'duration', with: 140

        find(:css, "#friends_#{user2.id}").set(true)

        find(:css, "#friends_#{user3.id}").set(true)

        find(:css, "#friends_#{user4.id}").set(true)

        click_button 'Create Party'
        expect(current_path).to eq(dashboard_path)

        expect(page).to have_content("Movie Title: Fight Club")
        expect(page).to have_content("Duration: 140")
        expect(page).to have_content("Email: #{user.email}")
        expect(page).to have_content("Invited To:")

        within("#hosting-viewing-parties") do
          expect(page).to_not have_content(user2.email)
          expect(page).to_not have_content(user3.email)
          expect(page).to_not have_content(user4.email)
        end
      end
    end
  end
end
