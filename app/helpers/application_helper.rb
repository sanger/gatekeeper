module ApplicationHelper

  def flash_message(category)
    {
      :success  => 'Success',
      :info     => 'Note',
      :warning  => 'Caution',
      :danger   => 'Sorry!'
    }[category]
  end

  def each_barcode_printer(type)
    (Settings.printers[type]||no_printer).each do |printer|
      yield printer[:name],printer[:uuid]
    end
  end

  def no_printer
    [{:name=>'No printer found',:uuid=>nil}]
  end
  private :no_printer

  #<span class="glyphicon glyphicon-icon"></span>
  def glyph(icon)
    content_tag(:span,'',:class => "glyphicon glyphicon-#{icon}")
  end

  #<span class="input-group-addon"><span class="glyphicon glyphicon-icon"></span></span>
  def input_glyph(icon)
    content_tag(:span, :class => "input-group-addon") do
      glyph(icon)
    end
  end

  def well_location_plate_letter_range_for(dim_x, dim_y)
    return range = ('A'..'H') if dim_y==8
    first_letter = 'A'
    last_letter = (first_letter.ord + (dim_y-1)).chr
    (first_letter..last_letter)
  end

  def well_location_for(pos, dim_x=12, dim_y=8)
    return nil if (pos >= (dim_x * dim_y))
    return nil if pos < 0
    l=well_location_plate_letter_range_for(dim_x, dim_y).to_a[pos%dim_y]
    v=(pos/dim_y)+1
    l+v.to_s
  end

end
