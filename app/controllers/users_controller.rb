# frozen_string_literal: true

class UsersController < ApplicationController
  # For confirming users exist, called by Javascript to '/users/search'
  def search
    begin
      swipecard_code = params[:user_swipecard]
      @user = Presenter::User.new(user_for_swipecard(swipecard_code))
    rescue JsonApiClient::Errors::NotFound
      return render(json: Presenter::User.new(nil).output, status: :not_found)
    end

    render(json: @user.output)
  end

  private

  def user_for_swipecard(swipecard_code)
    Sequencescape::Api::V2::User.find(user_code: swipecard_code).first
  end
end
