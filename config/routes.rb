Shopidav::Application.routes.draw do

  constraints(Shopidav::Constraints::Maindomain) do
    match 'welcome'            => 'home#welcome'
    match 'design'             => 'home#design'

    match 'login'              => 'login#index',        :as => :login
    match 'login/authenticate' => 'login#authenticate', :as => :authenticate
    match 'login/finalize'     => 'login#finalize',     :as => :finalize
    match 'login/logout'       => 'login#logout',       :as => :logout

    root :to                   => 'home#index'
  end

  constraints(Shopidav::Constraints::Subdomain) do
    mount DAV4Rack::Handler.new({
      :root => '',
      :root_uri_path => '/',
      :resource_class => ::Resources::Shop
    }), :at => '/'
  end

end
