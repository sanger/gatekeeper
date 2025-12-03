# frozen_string_literal: true

##
# Very simple presenter class for users
class Presenter::User
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def name
    [user.first_name, user.last_name].join(' ')
  end

  def login
    user.login
  end

  def output
    { 'user' => json }
  end

  private

  def json
    if @user.present?
      {
        'name' => name,
        'login' => login
      }
    else
      'not found'
    end
  end
end
