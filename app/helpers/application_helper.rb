module ApplicationHelper

  def progress_helper
    progress = {:total=>150}
    state_counts = {
      'created' => 30,
      'pending' => 40,
      'qc_in_progress' => 2,
      'passed'  => 2,
      'available' => 8,
      'failed' => 1,
      'destroyed' => 1,
      'exhausted' => 66
    }
    state_counts.inject(progress) do |i,state|
      i[state.first] = {:count=>state.last,:percent=>state.last*100.0/progress[:total]}
      i
    end
  end

end
