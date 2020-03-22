# frozen_string_literal: true

module Formify
  module ControllerHelpers # :nodoc:
    extend ActiveSupport::Concern

    included do
      def redirect_to_with_flash(*args, **keywords)
        keywords.slice(%i[danger info success]).each do |k, v|
          flash[k] = v
        end

        Rails.logger.info "Redirecting to: #{args.first}"

        super(*args, **keywords)
      end

      def render_form_result(form:, on_failure: nil, on_success: nil, result:)
        if result.success?
          if form.translation_success.present?
            flash[:success] = form.translation_success
          end
          on_success.call(result) if on_success.present?
        elsif on_failure.is_a?(Proc)
          flash[:danger] = result.error.message
          on_failure.call(result) if on_failure.present?
        else
          flash.now[:danger] = result.error.message
          render on_failure
        end

        yield(result) if block_given?
      end

      def save_and_render_form(form:, on_failure: nil, on_success: nil, &block)
        render_form_result(
          form: form,
          on_failure: on_failure,
          on_success: on_success,
          result: form.save,
          &block
        )
      end
    end
  end
end
