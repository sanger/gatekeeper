# frozen_string_literal: true

module ApplicationHelper
  DEFAULT_PRINTER_TYPE = '96 Well Plate'
  def flash_message(category)
    {
      success: 'Success',
      info: 'Note',
      warning: 'Caution',
      danger: 'Sorry!'
    }[category]
  end

  def each_barcode_printer(type)
    Settings.printers.fetch(type, no_printer).each do |printer|
      yield printer[:name], printer[:uuid]
    end
  end

  #
  # Renders a grouped list of barcode printers, with preferred type at the top
  # @param preferred_type [String] The printers to render at the top of the list.
  #
  # @return [String] The <option> tags for generating a select
  def barcode_printer_select_options(preferred_type = DEFAULT_PRINTER_TYPE)
    grouped_options_for_select(all_barcode_printers(preferred_type))
  end

  #
  # Returns a hash suitable for grouped_options_for_select
  # containing ALL barcode printers. The preferred type is listed
  # first.
  # @param preferred_type [String] A barcode printer type
  #
  # @return [Array] Array for rendering select
  def all_barcode_printers(preferred_type)
    sorted_barcode_printers(preferred_type).map do |group, printers|
      [
        group,
        printers.map { |printer| printer.values_at(:name, :uuid) }
      ]
    end
  end

  #
  # Returns an array of grouped barcode printers
  # with the prefered_type first.
  # @param preferred_type [String] The barcode printer type to show first
  #
  # @return [Array] array of printer types and their printers
  def sorted_barcode_printers(preferred_type)
    Settings.printers.sort_by { |type, _printers| type == preferred_type ? 0 : 1 }
  end

  def no_printer
    [{ name: 'No printer found', uuid: nil }]
  end
  private :no_printer

  # <span class="glyphicon glyphicon-icon"></span>
  def glyph(icon)
    content_tag(:span, '', class: "glyphicon glyphicon-#{icon}")
  end

  # <span class="input-group-addon"><span class="glyphicon glyphicon-icon"></span></span>
  def input_glyph(icon)
    content_tag(:span, class: 'input-group-addon') do
      glyph(icon)
    end
  end

  def well_location_plate_letter_range_for(dim_x, dim_y)
    return range = ('A'..'H') if dim_y == 8
    first_letter = 'A'
    last_letter = (first_letter.ord + (dim_y - 1)).chr
    (first_letter..last_letter)
  end

  def well_location_for(pos, dim_x = 12, dim_y = 8)
    if (pos < 0) || (pos >= (dim_x * dim_y))
      raise RangeError, 'Well location position is out of range'
    end
    l = well_location_plate_letter_range_for(dim_x, dim_y).to_a[pos % dim_y]
    v = (pos / dim_y) + 1
    l + v.to_s
  end
end
