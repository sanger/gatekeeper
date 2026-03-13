# frozen_string_literal: true

require 'test_helper'

class Presenter::RobotTest < ActiveSupport::TestCase
  test '#name and #bed_count' do
    robot = mock('robot')
    robot.stubs(:name).returns('Robot 1')
    robot.stubs(:robot_properties).returns({ 'max_plates' => '10' })
    robot.stubs(:present?).returns(true)

    presenter = Presenter::Robot.new(robot)
    assert_equal 'Robot 1', presenter.name
    assert_equal 9, presenter.bed_count
    assert_equal({ 'robot' => { 'name' => 'Robot 1', 'bed_count' => 9 } }, presenter.output)
  end

  test 'output when robot is nil' do
    presenter = Presenter::Robot.new(nil)
    assert_equal({ 'robot' => 'not found' }, presenter.output)
  end
end

class Presenter::UserTest < ActiveSupport::TestCase
  test '#name and #login' do
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
