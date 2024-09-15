def login(admin: false, early_access: false)
  @user = create(:user, admin:, early_access:)
  visit root_path
  click_button 'Login'
  fill_in 'signin-email', with: @user.email
  fill_in 'signin-password', with: @user.password
  click_button 'Sign in'
end
