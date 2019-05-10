module Formify
  module Errors
    class ValidationError < Formify::Errors::FormError
      attr_reader :attribute

      def initialize(form:)
        @attribute = form.errors.first.first

        super(
          form: form,
          message: form.errors.full_messages_for(@attribute).first
        )
      end
    end
  end
end
