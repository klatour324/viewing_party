require 'rails_helper'

describe 'Logging in' do
  it 'log user in' do
    user = User.create(email: "joeb@email.com", password: "test")
    visit root_path

    expect(page).to have_content("Welcome to the Viewing Party!")
    expect(page).to have_content("Here at viewing party we aim to give you an online movie experience so good you'll forget you can't go to the theater anymore!")

    expect(page).to have_link("Login")
    click_link "Login"

    expect(current_path).to eq(login_path)

    fill_in :email, with: user.email.upcase
    fill_in :password, with: user.password

    click_button 'Login'

    expect(current_path).to eq(dashboard_path)
    expect(page).to have_content("Welcome, #{user.email}")
  end

  describe 'sad path' do
    it 'block login if bad credentials' do
      user = User.create(email: "funbucket13@example.com", password: "test")

      visit root_path

      click_link 'Login'

      expect(current_path).to eq(login_path)

      fill_in :email, with: user.email
      fill_in :password, with: 'bad password'

      click_button 'Login'

      expect(current_path).to eq(login_path)
      expect(page).to have_content("Wrong email/password")
    end
  end

  it 'allows a user to log out' do
    user = User.create(email: "funbucket13@example.com", password: "test")

    visit root_path

    click_link 'Login'

    expect(current_path).to eq(login_path)

    fill_in :email, with: user.email
    fill_in :password, with: 'test'

    click_button 'Login'

    expect(current_path).to eq(dashboard_path)
    expect(page).to have_link('Log Out')
    
    click_link 'Log Out'

    expect(current_path).to eq(root_path)
    expect(page).to have_content('You have been successfully logged out')
  end
end
