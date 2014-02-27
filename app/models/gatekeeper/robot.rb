##
# Namespcaced Robot as per:
# https://github.com/sanger/sequencescape-client-api/wiki/Extending-the-Ruby-client-library
# Validates bed layouts

class Gatekeeper::Robot < Sequencescape::Robot

  require './lib/barcode'

  ##
  # Contains bed validation behaviour for the robot
  module ValidationMethods

    ##
    # Takes a hash of bed barcodes to assets/lots
    def valid?(lot_bed,lot,beds)
      valid_lot?(lot_bed,lot).tap do |valid,message|
        return [valid,message] unless valid
      end
      valid,message = true, ''
      each_destination_barcode do |barcode,name|
        qcable = beds.delete(barcode)
        return [false, "Bed #{name} should not be empty."] if qcable.nil?
        return [false, "#{qcable.human_barcode} is not in lot #{lot.lot_number}"] unless qcable.in_lot?(lot)
        return [false, "#{qcable.human_barcode} is '#{qcable.state}'; only '#{Gatekeeper::Application.config.stampable_state}' plates may be stamped."] unless qcable.stampable?
      end
      return [false, "Invalid beds: #{beds.keys.join(',')}"] unless beds.empty?
      return [true,'Okay']
    end

    ##
    # Checks that just the lot is valid (ie. it is a lot.)
    def valid_lot?(lot_bed,lot)
      (lot_bed == lot_bed_barcode) ?
        [true,'Okay'] :
        [false, "The lot plate should be placed on Bed #{lot_bed_name} to begin the process."]
    end

    def lot_bed_name
      robot_properties['SCRC1']
    end

    def lot_bed_barcode
      Barcode.calculate_barcode('BD',1).to_s
    end

    def each_destination_barcode
      1.upto(capacity) do |i|
        yield Barcode.calculate_barcode('BD',robot_properties["DEST#{i}"].to_i).to_s, i
      end
    end

    def capacity
      robot_properties['max_plates'] - 1
    end

  end

  include ValidationMethods

end
