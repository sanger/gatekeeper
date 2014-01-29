module Gatekeeper

  class Application < Sinatra::Base

    require 'erubis'
    set :public_folder, "#{Gatekeeper.config.root_dir}/public"

    get '/' do
      erb :index, :layout => :'layouts/application' #{}"And they're off #{Gatekeeper.application_string}"
    end

  end

end
