require 'shopify_api'
require 'dav4rack/resource'

module Shopidav

  class Resource < ::DAV4Rack::Resource

    def setup
      case public_path
      when /^\/$/
        @resource = Shopidav::Resources::Shop.new(self)

      when /^\/themes$/
        @resource = Shopidav::Resources::Themes.new(self)

      when /^\/themes\/(\d+)-[^\/]+$/
        @resource = Shopidav::Resources::Theme.new(self, $1.split('-').first)

      when /^\/themes\/(\d+)-[^\/]+\/([^\/]+)$/
        @resource = Shopidav::Resources::Bucket.new(self, $1.split('-').first, $2)

      when /^\/themes\/(\d+)-[^\/]+\/([^\/]+\/[^\/]+)$/
        @resource = Shopidav::Resources::Asset.new(self, $1.split('-').first, $2)

      end
    end

    # Name of the resource
    def name
      @resource.name
    end

    # If this is a collection, return the child resources.
    def children
      @resource.children
    end

    # Is this resource a collection?
    def collection?
      @resource.collection?
    end

    # Does this resource exist?
    def exist?
      @resource.exist?
    end

    # Return the creation time.
    def creation_date
      @resource.creation_date
    end

    # Return the time of last modification.
    def last_modified
      @resource.last_modified
    end

    # Return an Etag, an unique hash value for this resource.
    def etag
      @resource.etag
    end

    # Return the mime type of this resource.
    def content_type
      @resource.content_type
    end

    # Return the size in bytes for this resource.
    def content_length
      @resource.content_length
    end

    # HTTP GET request.
    #
    # Write the content of the resource to the response.body.
    def get(request, response)
      raise NotFound unless exist?
      @resource.get(request, response)
    end

    # HTTP PUT request.
    #
    # Save the content of the request.body.
    def put(request, response)
      #raise NotFound unless exist?
      @resource.put(request, response)
    end

    # HTTP POST request.
    #
    # Usually forbidden.
    def post(request, response)
      NotImplemented
    end

    # HTTP DELETE request.
    #
    # Delete this resource.
    def delete
      NotImplemented
    end

    # HTTP COPY request.
    #
    # Copy this resource to given destination resource.
    def copy(dest, overwrite=false)
      NotImplemented
    end

    # HTTP MOVE request.
    #
    # Move this resource to given destination resource.
    def move(dest, overwrite=false)
      NotImplemented
    end

    # Create this resource as collection.
    def make_collection
      NotImplemented
    end

    # Get the Rack session hash
    #
    # @return [Hash] the session data
    #
    def session
      request.env['rack.session']
    end

    # Get the {Shop} model for the current shop.
    #
    # @return [Shop] the current shop
    #
    def current_shop
      session[:current_shop]
    end

    # Get the API resource for the current shop.
    #
    # @return [ShopifyAPI::Shop] the current shop
    #
    def current_api_shop
      session[:current_api_shop]
    end

    # Authenticate the WebDAV request. On successful authentication
    # the {ShopifyAPI} is prepared for further requests.
    #
    # @param [String] username the basic auth user name
    # @param [String] username the basic auth user name
    # @return [Boolean] the authentication status
    #
    def authenticate(username, password)
      unless current_shop && current_api_shop
        session[:current_shop] = ::Shop.find_by_name("#{ request.env['HTTP_HOST'].split('.').first() }.myshopify.com")
        return false unless current_shop

        # TODO: Authenticate the user

        ShopifyAPI::Base.site = current_shop.api_url
        session[:current_api_shop] = ShopifyAPI::Shop.current
        return false unless current_api_shop

      else
        ShopifyAPI::Base.site = current_shop.api_url
      end

      true
    end

    # Get the authentication realm
    #
    # @return [String] the name of the realm
    #
    def authentication_realm
      'Shopify WebDAV access'
    end

    # Get the error message when authentication fails
    #
    # @return [String] the error message
    #
    def authentication_error_msg
      'You are not authorized to access the Shopify shop.'
    end

  end
end