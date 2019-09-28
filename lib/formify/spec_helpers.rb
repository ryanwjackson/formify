# frozen_string_literal: true

module Formify
  module SpecHelpers
    extend ActiveSupport::Concern

    included do
      let(:form) { described_class }
      let(:initialized_form) { initialize_form }
      let(:attributes_override) { {} }
      let(:attributes_to_pass) { attributes.merge(attributes_override) }

      let(:result) { do_result }

      let(:value) { do_value }

      let(:error) { result.error }
      let(:error_message) { result.error.message }

      def do_result
        initialized_form.save
      end

      def do_value
        result.value
      end

      def initialize_form
        form.new(attributes_to_pass)
      end

      # Common Expectation Helpers

      def expect_error_message(message)
        expect(error_message).to include(message)
      end

      def expect_error_with_attribute(attribute)
        expect(error.attribute.try(:to_sym)).to eq(attribute.to_sym)
      end

      def expect_error_with_attribute_value(attribute, value, error_attribute: nil, message: nil)
        initialized_form.send("#{attribute}=", value)
        expect_error_with_attribute(error_attribute || attribute)
        expect_error_message(message) if message
      end

      def expect_error_with_missing_attribute(attribute)
        raise 'No attribute' unless attributes.key?(attribute)

        attributes_to_pass.delete(attribute)
        expect_error_with_attribute(attribute)
      end

      def expect_invalid(*args, **keywords)
        expect_not_valid(*args, **keywords)
      end

      def expect_not_valid(attribute: nil, message: nil)
        expect_error_with_attribute(attribute) if attribute.present?
        expect_error_message(message) if message.present?

        expect(initialized_form).not_to be_valid
      end

      def expect_valid
        expect(initialized_form).to be_valid
      end

      def expect_valid_with_attribute_value(attribute, value)
        initialized_form.send("#{attribute}=", value)
        expect_valid
      end

      def expect_valid_with_missing_attribute(attribute)
        raise 'No attribute' unless attributes.key?(attribute)

        attributes_to_pass.delete(attribute)
        expect_valid
      end
    end
  end
end