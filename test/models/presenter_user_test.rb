# frozen_string_literal: true

require 'test_helper'

class Presenter::UserTest < ActiveSupport::TestCase
  test 'name and login' do
    user = mock('user')
    user.stubs(:first_name).returns('John')
    user.stubs(:last_name).returns('Doe')
    user.stubs(:login).returns('jdoe')
    user.stubs(:present?).returns(true)

    presenter = Presenter::User.new(user)
    assert_equal 'John Doe', presenter.name
    assert_equal 'jdoe', presenter.login
    assert_equal({ 'user' => { 'name' => 'John Doe', 'login' => 'jdoe' } }, presenter.output)
  end

  test 'output when user is nil' do
    presenter = Presenter::User.new(nil)
    assert_equal({ 'user' => 'not found' }, presenter.output)
  end
end
