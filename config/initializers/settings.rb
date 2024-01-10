# frozen_string_literal: true

class Settings
  class << self
    def respond_to?(method, include_private = false)
      super || instance.respond_to?(method, include_private)
    end

    def method_missing(method, *, &)
      instance.send(method, *, &)
    end
    protected :method_missing

    def configuration_filename
      File.join(File.dirname(__FILE__), '..', 'settings', "#{Rails.env}.yml")
    end
    private :configuration_filename

    def instance
      return @instance if @instance.present?
      @instance = Hashie::Mash.new(YAML.load(ERB.new(File.read(configuration_filename)).result))
    rescue Errno::ENOENT
      star_length = [96, 12 + configuration_filename.length].max
      $stderr.puts('*' * star_length)
      $stderr.puts "WARNING! No #{configuration_filename}"
      $stderr.puts "You need to run 'rake config:generate' and can ignore this message if that's what you are doing!"
      $stderr.puts('*' * star_length)
    end
  end
end

Settings.instance
