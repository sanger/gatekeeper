# frozen_string_literal: true

# Helper methods to assist with testing PMB
module PmbSupport
  def self.print_job_response(printer_name, template_id, labels = [])
    {
      data: {
        id: '',
        type: 'print_jobs',
        attributes: {
          printer_name: printer_name,
          label_template_id: template_id.to_s,
          labels: labels_to_label_hash(labels)
        }
      }
    }.to_json
  end

  def self.print_job_post(printer_name, template_id, labels = [])
    {
      data: {
        type: 'print_jobs',
        attributes: {
          printer_name: printer_name,
          label_template_id: template_id,
          labels: labels_to_label_hash(labels)
        }
      }
    }.to_json
  end

  def self.labels_to_label_hash(labels)
    {
      body: labels.map { |attributes| { main_label: attributes } }
    }
  end

  def self.label_template_response(id, name)
    {
      data:
        [
          {
            id: id.to_s,
            type: 'label_templates',
            attributes: { name: name }
          }
        ]
    }.to_json
  end
end
