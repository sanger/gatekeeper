module Gatekeeper

  class Application < Sinatra::Base

    require 'erubis'

    get '/' do
      erb :index, :layout => :'layouts/application' #{}"And they're off #{Gatekeeper.application_string}"
    end

  end

end
