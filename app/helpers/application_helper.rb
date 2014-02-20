module ApplicationHelper

  def flash_message(category)
    {
      :success  => 'Success',
      :info     => 'Note',
      :warning  => 'Caution',
      :danger   => 'Sorry!'
    }[category]
  end

end
