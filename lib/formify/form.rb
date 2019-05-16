# frozen_string_literal: true

module Formify
  module Form
    extend ActiveSupport::Concern

    included do
      include ActiveModel::Model
      define_model_callbacks :save

      include ActiveModel::Validations
      include ActiveModel::Validations::Callbacks


      def failure(*args)
        Resonad.Failure(*args)
      end

      def params
        self.class.params
      end

      def return_self
        Resonad.Success(self)
      end

      def success(*args)
        Resonad.Success(*args)
      end

      def translation_data
        {}
      end

      def self.translation_attributes_errors_key_base
        "activemodel.errors.models.#{name.underscore}.attributes"
      end

      def t(*args, **keywords)
        I18n.t(*args, **keywords)
      end

      def t_error(*args)
        I18n.t(self.class.t_error_key(*args))
      end

      def self.t_error_key(attribute, *keys)
        [
          translation_attributes_errors_key_base,
          attribute,
          *keys
        ].map(&:to_s).join('.')
      end

      def translation_success
        split_name = self.class.name.split('::')
        split_name.shift
        action = split_name.pop.underscore
        key = split_name.map(&:underscore).push(action).push(:success).join('.')
        return t(key) if I18n.exists?(key, translation_data)
      end

      def validate_or_fail(*instances)
        unless valid?
          return Resonad.Failure(
            Formify::Errors::ValidationError.new(form: self)
          )
        end

        if instances.present?
          instances.each do |instance|
            next if instance.valid?

            return Resonad.Failure(
              Formify::Errors::ValidationError.new(form: self, message: instance.full_messages.first)
            )
          end
        end

        Resonad.Success
      end

      def with_advisory_lock(*keys, **args)
        key = if keys.present?
                keys.map do |k|
                  if k.is_a?(String)
                    k
                  else
                    k.try(:id)
                  end
                end.join('/')
              else
                self.class.name.underscore
              end
        ActiveRecord::Base.with_advisory_lock(key, **args) { yield }
      end

      def with_advisory_lock_transaction(*keys)
        with_advisory_lock_transaction_result = Resonad.Failure

        with_advisory_lock(*keys, transaction: true) do
          ActiveRecord::Base.transaction do
            with_advisory_lock_transaction_result = begin
              yield
            end

            raise ActiveRecord::Rollback if with_advisory_lock_transaction_result.failure?
          end
        end

        with_advisory_lock_transaction_result
      end
    end

    class_methods do
      def attr_accessor(*attrs)
        @class_params ||= []
        @class_params.concat(attrs)
        super(*attrs)
      end

      def delegate_accessor(*args, **keywords)
        delegate(
          *args.map { |arg| [arg, "#{arg}="] }.flatten,
          **keywords
        )
      end

      def params
        @params ||= @class_params.reject { |e| %i[validation_context].include?(e) }
      end
    end
  end
end
