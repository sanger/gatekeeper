##
# Very simple presenter class for robots
class Presenter::Robot

  attr_reader :robot

  def initialize(robot)
    @robot= robot
  end

  def name
    robot.name
  end

  def bed_count
    robot.robot_properties['max_plates'].to_i-1
  end

  def output
    @robot.present? ? { 'robot' =>
      {
        'name' => name,
        'bed_count' => bed_count
      }
    } : {'robot'=>'not found'}
  end

end
