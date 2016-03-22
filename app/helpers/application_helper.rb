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

end
