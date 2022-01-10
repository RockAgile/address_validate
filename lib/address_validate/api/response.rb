module AddressValidate
  module API
    class Response
      attr_reader :response_body, :raw_response_body

      def initialize(response_body)
        @raw_response_body = response_body
        @response_body = Ox.parse(response_body)
      end

      def success?
        errors.nil?
      end

      def error
        AddressValidate::API::Error.new(errors) if errors
      end

      def data
        @data ||= errors ? {} : parse_data
      end

      def warning
        get_field('ReturnText')
      end

      def to_xml
        Ox.dump(response_body)
      end

      def to_h
        Hash.from_xml(Ox.dump(response_body))
      end

    private

      def errors
        @errors ||= address_data.locate('Error').first
      end

      def address_data
        @address_data ||= response_body.AddressValidateResponse.Address
      end

      def parse_data
        {}.tap do |data|
          AddressValidate.address_fields_map.each do |field, name|
            data[name] = get_field(field)
          end
        end
      end

      def get_field(field_name)
        field = address_data.locate(field_name).first
        field.text if field
      end
    end
  end
end
