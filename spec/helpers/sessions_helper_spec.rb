require 'rails_helper'

def log_in email: "oscar@gmail.com", password: "password"
  visit '/sessions/new' unless current_path == "/sessions/new"
  fill_in 'Email', with: email
  fill_in 'Password', with: password
  click_button 'Log In'
end

def log_in(user)
  session[:user_id] = user.id
  session[:name] = user.name
  if !user.isAdmin
    group_id = Person.select('group_id').find_by name: @user.name
    puts "*******group_id is "+group_id.to_s
    session[:group_id] = group_id
  end
end
def log_out
  session.delete(:user_id)
  session.delete(:group_id)
  session.delete(:name)
  @current_user = nil
end

# Specs in this file have access to a helper object that includes
# the SessionsHelper. For example:
#
# describe SessionsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe SessionsHelper, type: :helper do
  pending "add some examples to (or delete) #{__FILE__}"
end
