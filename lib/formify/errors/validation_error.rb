module Formify
  module Errors
    class ValidationError < Formify::Errors::FormError
      attr_reader :attribute

      def initialize(form:)
        first_error = form.errors.first
        @attribute = if first_error.methods.include?(:attribute)
                       first_error.attribute
                     else
                       first_error.first
                     end

        super(
          form: form,
          message: form.errors.full_messages_for(@attribute).first
        )
      end
    end
  end
end
