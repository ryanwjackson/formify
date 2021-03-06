# frozen_string_literal: true

module Formify
  module ControllerHelpers # :nodoc:
    extend ActiveSupport::Concern

    included do
      def formify_flash_keys
        @formify_flash_keys ||= %i[danger info success]
      end

      def formify_params(root, *permitted)
        params
          .permit(
            root => permitted
          )[root]
      end

      def formify_redirect_to_with_flash(*args, **keywords)
        formify_set_flashes(keywords)
        Rails.logger.info "Redirecting to: #{args.first}"
        redirect_to(*args, **keywords.except(formify_flash_keys))
      end

      def formify_render_form_result(form:, on_failure: nil, on_success: nil, result:)
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

      def formify_save_and_render_form(form:, on_failure: nil, on_success: nil, &block)
        formify_render_form_result(
          form: form,
          on_failure: on_failure,
          on_success: on_success,
          result: form.save,
          &block
        )
      end

      def formify_set_flashes(messages = {})
        messages.slice(*formify_flash_keys).each do |k, v|
          flash[k] = v
        end
      end
    end
  end
end
