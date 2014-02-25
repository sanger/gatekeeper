module MockApi

  require 'hashie'

  ##
  # A mocked Api for use during testing
  # Uses ./test/fixtures/api_models.yml to respond to queries
  class Api < ActionController::TestCase

    class TestError < StandardError; end

    ##
    # eg. api.lot
    class Resource

      attr_reader :name

      def initialize(resource_name)
        @name = resource_name
      end

      def find(uuid)
        resource_cache[uuid] ||= Record.from_registry(name,uuid)
      end

      alias_method :with_uuid, :find

      ##
      # Receives a hash
      # :received => The arguments create expects to see (optional)
      # :returns  => The UUID of the returned resource, which should exist in the registry.
      def expect_create_with(options)
        received = options.delete(:received)
        returned = Record.from_registry(name,options.delete(:returns))
        raise StandardError, "Creation expected with invalid options #{options.keys.join(',')}" unless options.empty?
        if received.present?
          self.expects(:create!).with(received).returns(returned)
        else
          self.expects(:create!).returns(returned)
        end
      end

      def create!(*args)
        raise Api::TestError, "Unexpected create! received with options #{args.inspect}"
      end

      private

      def resource_cache
        @resource_cache ||= Hash.new
      end

    end

    ##
    # An association proxy is a bit like a resource. In practice its a bit more complicated
    # than the mocked up version, as it doesn't end up at the same place as the base resource.
    # However, we don't really care about that here, as that's outside the scope of the tests.
    class Association < Resource
      def initialize(parent,resource_name,records)
        @name = resource_name
        @parent = parent
        if records.is_a?(Array)
          @records = records.map {|uuid| Record.from_registry(resource_name,uuid)}
        else
          @records = Record.from_registry(resource_name,records)
        end
      end

      ##
      # Method missing first tries passing things on to the association array
      def method_missing(method_name,*args,&block)
        return @records.send(:"#{method_name}",*args,&block) if @records.respond_to?(:"#{method_name}")
        super
      end
    end

    ##
    # An instance of a resource
    class Record

      class << self
        ##
        # Initialise a record from the corresponding registry entry
        def from_registry(model_name,uuid)
          Record.new(Registry.instance.find(:"#{model_name}",uuid),model_name,uuid)
        end
      end

      def initialize(record,model_name,uuid)
        @record = record
        @uuid = uuid
        @model_name = model_name
      end

      attr_reader :uuid, :model_name
      alias_method :id, :uuid

      def method_missing(method_name)
        return lookup_attribute(method_name) if @record[:attributes].has_key?(method_name)
        lookup_association(method_name)||super
      end

      ##
      # Used by rails to resolve urls
      def to_param
        uuid
      end

      private

      def attribute_cache
        @attribute_cache ||= Hash.new
      end

      def association_cache
        @association_cache ||= Hash.new
      end

      def lookup_attribute(attribute)
        attribute_cache[attribute] ||= @record[:attributes][attribute]
      end

      def lookup_association(assn)
        return nil unless @record[:associations].has_key?(assn)
        association_cache[assn] ||= Association.new(self,assn.to_s.singularize,@record[:associations][assn]||[])
      end
    end

    def initialize(api_mock)
      @api = api_mock
      Registry.instance.each_resource do |resource|
        add_resource(resource)
      end
    end

    def add_resource(resource_name)
      Resource.new(resource_name).tap do |resource|
        @api.stubs(resource_name).returns(resource)
      end
    end

    ##
    # Mocks a user. Refactor to use the registry
    def mock_user(barcode,uuid)
      mock('user').tap do |user|
        user.stubs('uuid').returns(uuid)
        mock_user_shared(user,barcode)
      end
    end

    private

    def method_missing(method)
      @api.send(method)
    end

    def mock_user_shared(user,barcode)
      user_search = @api.search.with_uuid('e7e52730-956f-11e3-8255-44fb42fffecc')
      user_search.stubs(:first).raises(StandardError,'There is an issue with the API connection to Sequencescape (["no resources found with that search criteria"])')
      user_search.stubs(:first).with(:swipecard_code => barcode).returns(user)
    end

  end

  def mock_api
    @api = Api.new(mock('api')).tap do |mock|
      Sequencescape::Api.stubs(:new).returns(mock)
    end
  end

  def api; @api; end

  class Registry

    include Singleton

    def registry
      @registry ||= Hashie::Mash.new(YAML.load(eval(ERB.new(File.read('./test/fixtures/api_models.yml')).src, nil, '../fixtures/api_models.yml')))
    end

    def each_resource
      registry.each {|resource,records| yield resource }
    end

    def find(resource,uuid)
      raise Api::TestError, "No resouce found for #{resource}" if registry[resource].nil?
      registry[resource][uuid] || raise(StandardError, "There is an issue with the API connection to Sequencescape (UUID does not exist)")
    end

  end


end
