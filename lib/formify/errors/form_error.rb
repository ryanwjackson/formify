module Formify
  module Errors
    class FormError < StandardError
      attr_reader :form

      def initialize(form:, message:)
        @form = form
        super(message)
      end
    end
  end
end
