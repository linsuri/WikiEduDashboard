# frozen_string_literal: true

require 'rails_helper'

describe 'onboarding', type: :feature, js: true do
  before { stub_list_users_query }

  let(:user) { create(:user, onboarded: onboarded, real_name: 'test', email: 'email@email.com') }

  describe 'onboarding redirect checks' do
    describe 'when not logged in' do
      let(:onboarded) { false }

      it 'is not able to access onboarding' do
        visit onboarding_path
        expect(page.current_path).to eq root_path
      end
    end

    describe 'when logged in and not onboarded' do
      let(:onboarded) { false }

      before do
        login_as(user, scope: :user)
      end

      it 'is able to access onboarding' do
        visit onboarding_path
        expect(page).to have_content 'excited'
      end

      it 'is not able to access other parts of the app' do
        visit explore_path
        expect(page.current_path).to eq onboarding_path
      end

      it 'is able to log out' do
        visit destroy_user_session_path
        expect(page.current_path).to eq root_path
      end
    end
  end

  describe 'onboarding forms' do
    let(:onboarded) { false }

    before do
      login_as(user, scope: :user)
    end

    it 'pre-populates' do
      visit onboarding_path
      find('.intro .button').click
      expect(find('input[name=name]').value).to eq 'test'
      expect(find('input[name=email]').value).to eq 'email@email.com'
    end

    it 'updates user when submitted' do
      visit onboarding_path
      find('.intro .button').click
      find('input[type=radio][value=true]').click
      find('form button[type=submit]').click
      sleep 1
      expect(user.reload.onboarded).to eq true
      expect(user.permissions).to eq User::Permissions::INSTRUCTOR
    end
  end

  describe 'onboarding supplement' do
    let(:onboarded) { false }

    before do
      login_as(user, scope: :user)
    end

    it 'goes to supplementary' do
      visit onboarding_path
      find('.intro .button').click
      find('input[type=radio][value=true]').click
      find('form button[type=submit]').click
      page.assert_selector('form#supplementary')
      fill_in 'heardFrom', with: 'twitter'
      click_button 'Submit'
    end
  end
end
