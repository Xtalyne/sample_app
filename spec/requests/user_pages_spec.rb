require 'spec_helper'

describe "UserPages" do

	subject { page }

	describe "signup page" do
		before { visit signup_path }

		it { should have_selector('h1',    text: 'Sign up') }
		it { should have_selector('title', text: full_title('Sign up')) }
	end

	describe "profile page" do
		let(:user) { FactoryGirl.create(:user) }
		before { visit user_path(user) }

		it { should have_selector('h1', 	text: user.name) }
		it { should have_selector('title', 	text: user.name) }
	end


	describe "signup" do

		before { visit signup_path }

		let(:submit) { "Create my account" }

		describe "with invalid information" do
			it "should not create a user" do
				expect { click_button submit }.not_to change(User, :count)
			end

			describe "after submission" do
				before { click_button submit }
				it { should have_selector('title', text: 'Sign up') }
				it { should have_content('error') }
				it { should have_content('Name can\'t be blank') }
				it { should have_content('Email can\'t be blank') }
				it { should have_content('Password can\'t be blank') }
				it { should have_content('Password confirmation can\'t be blank') }
			end

			describe "after submission with name that is too long" do
				before do
					fill_in "Name", with: "a" * 51
					click_button submit
				end
				it { should have_content('Name is too long') }
			end

			describe "after submission when email is invalid" do
				# TODO: determine way to attempt (if necessary) multiple invalid addresses	
				before do
				#	addresses = %w[user@foo,com user_at_foo.org example.user@foo.
				#					foo@bar_baz.com foo@bar+baz.com]
				#	addresses.each do |invalid_address|
					fill_in "Email", with: "user@foo,com"
					click_button submit
				end
				it { should have_content('Email is invalid') }
			end

			describe "after submission when email is already taken" do
				before do
					fill_in "Name", 		with: "Example User"
					fill_in "Email", 		with: "user@example.com"
					fill_in "Password",		with: "foobar"
					fill_in "Confirmation", with: "foobar"
					click_button submit
					visit signup_path
					fill_in "Name", 		with: "Example User"
					fill_in "Email", 		with: "user@example.com"
					fill_in "Password",		with: "foobar"
					fill_in "Confirmation", with: "foobar"
					click_button submit
				end
				it { should have_content('Email has already been taken') }
			end

			describe "after submission when the password is too short" do
				before do
					fill_in "Password", with: "a"
					click_button submit
				end
				it { should have_content('Password is too short') }
			end

			describe "after submission when password does not match confirmation" do
				before do
					fill_in "Password", with: "foobar"
					fill_in "Confirmation", with: "foobar2"
					click_button submit
				end
				it { should have_content('Password doesn\'t match confirmation') }
			end

		end # end "with invalid information" block


		describe "with valid information" do
			before do
				fill_in "Name", 		with: "Example User"
				fill_in "Email", 		with: "user@example.com"
				fill_in "Password",		with: "foobar"
				fill_in "Confirmation", with: "foobar"
			end

			it "should create a user" do
				expect { click_button submit }.to change(User, :count).by(1)
			end

			describe "after saving the user" do
				before { click_button submit }
				let(:user) { User.find_by_email('user@example.com') }

				it { should have_selector('title', text: user.name) }
				it { should have_selector('div.alert.alert-success', text: 'Welcome') }
				it { should have_link('Sign out') }
			end

		end  # end "with valid information" block

	end
	
end
