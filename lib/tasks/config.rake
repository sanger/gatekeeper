# frozen_string_literal: true

namespace :config do
  desc 'Generates a configuration file for the current Rails environment'

  task generate: :environment do
    api = Sequencescape::Api.new(Gatekeeper::Application.config.api_connection_options)

    # Build the configuration file based on the server we are connected to.
    CONFIG = {}.tap do |configuration|
      configuration[:searches] = {}.tap do |searches|
        puts 'Preparing searches ...'
        api.search.each do |search|
          searches[search.name] = search.uuid
        end
      end

      configuration[:printers] = Hash.new { |h, i| h[i] = Array.new }.tap do |printers|
        approved_printers = Gatekeeper::Application.config.approved_printers
        puts 'Preparing printers ...'
        selected = Sequencescape::Api::V2::BarcodePrinter.all.select { |printer| printer.active && (approved_printers == :all || approved_printers.include?(printer.name)) }
        selected.each { |printer| printers[printer.barcode_type] << { name: printer.name, uuid: printer.uuid } }
      end

      configuration[:lot_types] = {}.tap do |lot_types|
        puts 'Preparing lot types ...'
        # Rubocop is wrong here - find_each is an unknown method
        Sequencescape::Api::V2::LotType.all.each do |lot_type| # rubocop:disable Rails/FindEach
          lot_types[lot_type.name] = { uuid: lot_type.uuid, template_class: lot_type.template_class, printer_type: lot_type.printer_type, qcable_name: lot_type.qcable_name }
        end
      end
    end

    # Write out the current environment configuration file
    Rails.root.join('config', 'settings', "#{Rails.env}.yml").open('w') do |file|
      file.puts(CONFIG.to_yaml)
    end
  end

  task default: :generate
end
