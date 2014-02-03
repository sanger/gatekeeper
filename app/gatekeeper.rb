module Gatekeeper

  class Application < Sinatra::Base

    require 'erubis'

    helpers do
      # This code is just here during development, it should get moved onto a model/presenter
      def progress_helper
        progress = {:total=>150}
        state_counts = {
          'created' => 30,
          'pending' => 40,
          'qc_in_progress' => 2,
          'passed'  => 2,
          'available' => 8,
          'failed' => 1,
          'destroyed' => 1,
          'exhausted' => 66
        }
        state_counts.inject(progress) do |i,state|
          i[state.first] = {:count=>state.last,:percent=>state.last*100.0/progress[:total]}
          i
        end
      end
    end

    register Sinatra::Partial

    set :partial_template_engine, :erb
    set :public_folder, "#{Gatekeeper.config.root_dir}/public"
    enable :partial_underscores


    get '/' do
      erb :index, :layout => :'layouts/application'
    end

    get %r{/idt/(\h{8}-\h{4}-\h{4}-\h{4}-\h{12})} do |uuid|
      erb :'idt_stock/show', :layout => :'layouts/application'
    end

  end

end
