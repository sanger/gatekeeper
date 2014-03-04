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
    def valid?(lot_bed,lot,beds_orj)
      beds = beds_orj.dup
      valid_lot?(lot_bed,lot).tap do |valid,message|
        return [valid,message] unless valid
      end
      valid,message = true, ''
      each_destination_barcode do |barcode,name|
        qcable = beds.delete(barcode)
        return [false, "Bed #{name} should not be empty. #{barcode}"] if qcable.nil?
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
        [true,'Correct bed used.'] :
        [false, "The lot plate should be placed on Bed #{lot_bed_name} to begin the process."]
    end

  end

  module BasicMethods
    def lot_bed_name
      robot_properties['SCRC1']
    end

    def lot_bed_barcode
      Barcode.calculate_barcode('BD',robot_properties['SCRC1'].to_i).to_s
    end

    def each_destination_barcode
      1.upto(capacity) do |i|
        yield barcode_for(i), robot_properties["DEST#{i}"]
      end
    end

    def barcode_for(i)
      Barcode.calculate_barcode('BD',robot_properties["DEST#{i}"].to_i).to_s
    end

    def capacity
      robot_properties['max_plates'].to_i - 1
    end
  end

  module CreationMethods
    def beds_for(beds)
      (1..capacity).map do |i|
        {:bed=>robot_properties["DEST#{i}"], :order=>i, :qcable=>beds[barcode_for(i)].uuid }
      end
    end
  end

  include BasicMethods
  include ValidationMethods
  include CreationMethods

end
