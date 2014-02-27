module Barcode
  InvalidBarcode = Class.new(StandardError)

  def self.calculate_barcode(prefix, number)
    barcode = calculate_sanger_barcode(prefix, number)
    barcode*10+calculate_EAN13(barcode)
  end

  # NT23432S => 398002343283
  private

  def self.calculate_sanger_barcode(prefix, number)
      raise ArgumentError, "Number : #{number} to big to generate a barcode." if number.to_s.size > 7
      checksum = calculate_checksum(prefix, number)
      barcode = prefix_to_number(prefix) + (number * 100) + checksum
  end

  def self.calculate_checksum(prefix, number)
    string = prefix + number.to_s
    len  = string.length

    sum = (0...len).inject(0) do |s,i|
      s + (string.getbyte(i) * (len-i))
    end
    (sum % 23 + 'A'.getbyte(0))
  end


  def self.calculate_EAN13(code)
    calculate_EAN(code)
  end

  def self.calculate_EAN(code, initial_weight=3)
    #The EAN is calculated by adding each digit modulo 10 ten weighted by 1 or 3 ( in seq)
    code = code.to_i
    ean = 0
    weight = initial_weight
    while code >0
      code, c = code.divmod 10
      ean += c*weight % 10
      weight = weight == 1 ? 3 : 1
    end
    (10 -ean) % 10
  end

  def self.prefix_to_number(prefix)
    first  = prefix.getbyte(0)-64
    second = prefix.getbyte(1)-64
    first  = 0 if first < 0
    second  = 0 if second < 0
    return ((first * 27) + second) * 1000000000
  end


end
