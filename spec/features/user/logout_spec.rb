require 'rails_helper'

describe 'Logging out' do
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