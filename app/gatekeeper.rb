module Gatekeeper

  class Application < Sinatra::Base

    require 'erubis'
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
