# frozen_string_literal: true

namespace :config do
  desc 'Generates a configuration file for the current Rails environment'

  task generate: :environment do
    api = Sequencescape::Api.new(Gatekeeper::Application.config.api_connection_options)

    barcode_printer_uuid = lambda do |printers|
      ->(printer_name) {
        printers.detect { |prt| prt.name == printer_name }.try(:uuid) ||
          raise("Printer #{printer_name}: not found!")
      }
    end.(api.barcode_printer.all)

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
        selected = api.barcode_printer.all.select { |printer| printer.active && (approved_printers == :all || approved_printers.include?(printer.name)) }
        selected.each { |printer| printers[printer.type.name] << { name: printer.name, uuid: printer.uuid } }
      end

      # Might want to switch this out for something more dynamic, but seeing as we'll almost certainly be working with a filtered set
      # caching it makes sense, as it'll speed things up.

      configuration[:templates] = {}.tap do |templates|
        # Plates
        puts 'Preparing plate templates ...'
        approved_plate_templates = Gatekeeper::Application.config.suggested_templates.plate_template
        plate_templates = api.plate_template.all.select { |template| approved_plate_templates == :all || approved_plate_templates.include?(template.name) }
        templates[:plate_template] = plate_templates.map { |template| { name: template.name, uuid: template.uuid } }

        # Tag Templates
        # puts "Preparing tag templates ..."
        # approved_tag_layout_templates = Gatekeeper::Application.config.suggested_templates.tag_layout_template
        # tag_layout_templates = api.tag_layout_template.all.select {|template| approved_tag_layout_templates == :all || approved_tag_layout_templates.include?(template.name) }
        # templates[:tag_layout_template] = tag_layout_templates.map {|template| {name: template.name, uuid: template.uuid }}

        # Tag 2 Templates
        # puts "Preparing tag 2 templates ..."
        # tag2_layout_templates = api.tag2_layout_template.all
        # templates[:tag2_layout_template] = tag2_layout_templates.map {|template| {name: template.name, uuid: template.uuid }}
      end

      configuration[:transfer_templates] = {}.tap do |transfer_templates|
        # Plates
        puts 'Preparing transfer templates ...'
        api.transfer_template.each do |template|
          next unless ['Whole plate to tube', 'Transfer columns 1-12', 'Flip Plate', 'Transfer between specific tubes'].include?(template.name)
          transfer_templates[template.name] = template.uuid
        end
      end

      configuration[:lot_types] = {}.tap do |lot_types|
        puts 'Preparing lot types ...'
        api.lot_type.each do |lot_type|
          lot_types[lot_type.name] = { uuid: lot_type.uuid, template_class: lot_type.template_class, printer_type: lot_type.printer_type, qcable_name: lot_type.qcable_name }
        end
      end

      configuration[:purposes] = {}.tap do |purpose|
        puts 'Preparing purposes ...'
        puts '... plates'
        raise 'No default purpose configuration specified.' if Gatekeeper::Application.config.default_purpose_handler.nil?
        api.plate_purpose.each do |plate_purpose|
          # Loads the default purpose info
          if Gatekeeper::Application.config.default_purpose_handler[:child_name] == plate_purpose.name
            configuration[:default_purpose] = Gatekeeper::Application.config.default_purpose_handler.merge(
              children: [plate_purpose.uuid],
              type: 'plate'
            )
          end
          next unless Gatekeeper::Application.config.tracked_purposes.include?(plate_purpose.name)
          purpose[plate_purpose.uuid] = {
            name: plate_purpose.name,
            children: plate_purpose.children.map { |c| c.uuid },
            type: 'plate'
          }.merge(Gatekeeper::Application.config.purpose_handlers[plate_purpose.name] || {})
        end
        puts '... tubes'
        api.tube_purpose.each do |tube_purpose|
          next unless Gatekeeper::Application.config.tracked_purposes.include?(tube_purpose.name)
          purpose[tube_purpose.uuid] = {
            name: tube_purpose.name,
            children: tube_purpose.children.map { |c| c.uuid },
            type: 'tube'
          }.merge(Gatekeeper::Application.config.purpose_handlers[tube_purpose.name] || {})
        end
      end

      configuration[:submission_templates] = {}.tap do |submission_templates|
        puts 'Preparing submission templates...'
        submission_templates['miseq'] = api.order_template.all.detect { |ot| ot.name == 'MiSeq for TagQC' }.uuid
      end

      puts 'Setting study...'
      configuration[:study] = Gatekeeper::Application.config.study_uuid ||
                              puts('No study specified, using first study') ||
                              api.study.first.uuid
      puts 'Setting project...'
      configuration[:project] = Gatekeeper::Application.config.project_uuid ||
                                puts('No project specified, using first project') ||
                                api.project.first.uuid
    end

    # Write out the current environment configuration file
    Rails.root.join('config', 'settings', "#{Rails.env}.yml").open('w') do |file|
      file.puts(CONFIG.to_yaml)
    end
  end

  task default: :generate
end
