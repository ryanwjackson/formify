# frozen_string_literal: true

require 'rails/generators/named_base'

class FormGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)
  # check_class_collision

  argument  :form_attributes,
            type: :array,
            required: true,
            description: 'A list of attributes and their delegates: foo:bar,baz'

  def validate_fixed_attrs
    return unless duplicate_attributes.any?

    raise "Cannot have duplicate attributes: #{duplicate_attributes.join(', ')}"
  end

  def generate_form
    template 'form.rb', File.join('app/lib/forms', class_path, "#{file_name}.rb")
  end

  def generate_form_spec
    template 'form_spec.rb', File.join('spec/lib/forms', class_path, "#{file_name}_spec.rb")
  end

  private

  def all_attributes
    @all_attributes ||= form_attributes
                        .map { |e| e.split(/:|,/).map(&method(:variablefy)) }
                        .flatten
                        .map(&:strip)
                        .sort
  end

  def attributes
    @attributes ||= attributes_and_delegates.keys.sort
  end

  def attributes_and_delegates
    @attributes_and_delegates ||= Hash[
      form_attributes
        .map { |e| e.split(/:|,/).map(&method(:variablefy)) }
        .collect { |v| [v[0], v[1..-1]] }
    ]
  end

  def delegated_attributes
    @delegated_attributes ||= attributes_and_delegates
      .select { |_k, v| v.sort!.present? }
  end

  def duplicate_attributes
    @duplicate_attributes ||= all_attributes
                              .group_by { |e| e }
                              .select { |_k, v| v.size > 1 }
                              .map(&:first)
  end

  def inferred_model_name
    @inferred_model_name ||= name.split('/')[-2].singularize.camelcase
  end

  def module_namespacing(&block)
    content = capture(&block)
    modules.reverse.each do |mod|
      content = wrap_with_module(content, mod)
    end
    concat(content)
  end

  def modules
    @modules ||= ['Forms'] + name.split('/')[0..-2].map(&:to_s).map(&:camelcase)
  end

  def variablefy(val)
    val.to_s.underscore
  end

  def wrap_with_module(content, mod)
    content = indent(content).chomp
    "module #{mod}\n#{content}\nend\n"
  end
end
