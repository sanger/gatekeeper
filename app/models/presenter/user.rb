##
# Very simple presenter class for users
class Presenter::User

  attr_reader :user

  def initialize(user)
    @user= user
  end

  def name
    [user.first_name,user.last_name].join(' ')
  end

  def login
    user.login
  end

  def output
    { 'user' => json }
  end

  private

  def json
    @user.present? ? {
      'name' => name,
      'login' => login
    } : 'not found'
  end

end
