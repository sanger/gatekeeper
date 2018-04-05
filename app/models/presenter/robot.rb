# frozen_string_literal: true

##
# Very simple presenter class for robots
class Presenter::Robot
  attr_reader :robot

  def initialize(robot)
    @robot = robot
  end

  def name
    robot.name
  end

  def bed_count
    robot.robot_properties['max_plates'].to_i - 1
  end

  def output
    { 'robot' => json }
  end

  private

  def json
    @robot.present? ? {
      'name' => name,
      'bed_count' => bed_count
    } : 'not found'
  end
end
