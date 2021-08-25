# frozen_string_literal: true

# Translates the label information into the correct format for the template
class BarcodeSheet::Label
  #
  # Create a label with the information expected to appear.
  # JG note: As of Feb 2019 we are only sending the prefix/number across the old
  # api, not the human readable for itself. This adds forward compatibility for passing
  # through a human readable form, which will be important if we change our barcode
  # format.
  # @param barcode: [String] The actual value of the barcode
  # @param prefix: [String] the prefix of the human readable barcode
  # @param number: [String] the number of the human readable barcode
  # @param human_readable: [String] the human readable barcode (if prefix and number aren't suitable)
  # @param lot: [String] The lot number
  # @param template: [String] The template name
  # @param study: [String] Legacy compatibility field
  #
  # @return [type] [description]
  def initialize(prefix:, number:, lot: nil, template: nil, barcode: nil, human_readable: nil, study: nil)
    @barcode = barcode
    @prefix = prefix
    @number = number
    @human_readable = human_readable
    @lot = lot
    @template = template
    @legacy_study = study
  end

  # Payload suitable for a 96 well plate
  # label template for PMB v1 Toshiba printers
  def plate
    {
      main_label: {
        top_left: date,
        bottom_left: human_readable,
        top_right: human_readable,
        bottom_right: lot_template,
        barcode: code39_barcode
      }
    }
  end

  # Payload suitable for a tube label template
  # label template for PMB v1 Toshiba printers
  def tube
    {
      main_label: {
        top_line: lot_template,
        middle_line: @number,
        bottom_line: date,
        round_label_top_line: @prefix,
        round_label_bottom_line: @number,
        barcode: ean13_barcode.to_s
      }
    }
  end

  # Payload suitable for 2 x 384 well plate label template
  # label template for PMB v1 Toshiba printers
  def plate_double
    {
      main_label: {
        left_text: human_readable,
        right_text: date,
        barcode: code39_barcode
      },
      extra_label: {
        left_text: lot_template
      }
    }
  end

  private

  def code39_barcode
    @barcode || SBCF::SangerBarcode.new(prefix: @prefix, number: @number).human_barcode
  end

  def lot_template
    @legacy_study || "#{@lot}:#{@template}"
  end

  def ean13_barcode
    @barcode || SBCF::SangerBarcode.new(prefix: @prefix, number: @number).machine_barcode
  end

  def human_readable
    @human_readable || SBCF::SangerBarcode.new(prefix: @prefix, number: @number).human_barcode
  end

  def date
    Time.zone.today.strftime('%d-%b-%Y')
  end
end
