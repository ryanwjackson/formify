# frozen_string_literal: true

require 'rails/generators/named_base'

class FormGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)
  # check_class_collision

  argument  :form_attributes,
            type: :array,
            required: true,
            description: 'A list of attributes and their delegates: foo:bar,baz'

  class_option  :pluralize_collection,
                default: true,
                description: 'Disable naming convention transformations like forcing plural collections',
                type: :boolean

  def transform_naming
    return unless pluralize_collection?

    self.name = begin
      names = name.split('/')
      names[0..-3].append(names[-2].pluralize).append(names[-1]).join('/')
    end
  end

  def validate_fixed_attrs
    return unless duplicate_attributes.any?

    raise "Cannot have duplicate attributes: #{duplicate_attributes.join(', ')}"
  end

  def generate_form
    template 'form.rb', File.join('app/lib/forms', transformed_class_path, "#{file_name}.rb")
  end

  def generate_form_spec
    template 'form_spec.rb', File.join('spec/lib/forms', transformed_class_path, "#{file_name}_spec.rb")
  end

  private

  def all_attributes
    @all_attributes ||= form_attributes
                        .map { |e| e.split(/:|,/).map(&method(:variablefy)) }
                        .flatten
                        .map(&:strip)
                        .sort
  end

  def attributes_with_delegates
    @attributes_with_delegates ||= attributes_and_delegates
      .select { |k, v| v.present? }
      .keys
      .sort
  end

  def attributes_and_delegates
    @attributes_and_delegates ||= Hash[
      form_attributes
        .map { |e| e.split(/:|,/).map(&method(:variablefy)) }
        .collect { |v| [v[0], v[1..-1]] }
    ]
  end

  def collection
    @collection ||= split_name[-2].pluralize.underscore
  end

  def collection_name
    @collection_name ||= collection.camelcase
  end

  def create?
    form.downcase.include?('create')
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

  def form
    @form ||= name.split('/').last.to_s.underscore
  end

  def form_name
    @form_name ||= form.camelcase
  end

  def inferred_model_name
    @inferred_model_name ||= collection.singularize.camelcase
  end

  def module_namespacing(&block)
    content = capture(&block)
    modules.reverse.each do |mod|
      content = wrap_with_module(content, mod)
    end
    concat(content)
  end

  def modules
    @modules ||= ['Forms'] + split_name[0..-2].map(&:to_s).map(&:camelcase)
  end

  def pluralize_collection?
    @pluralize_collection ||= options[:pluralize_collection]
  end

  def return_attribute
    @return_attribute ||= begin
      if all_attributes.include?(collection.singularize)
        collection.singularize
      else
        form_attributes.split(':').first
      end
    end
  end

  def scopes
    @scopes ||= split_name[0..-3].map(&:underscore)
  end

  def scope_names
    @scope_names ||= scopes.map(&:camelcase)
  end

  def split_name
    @split_name ||= name.split('/')
  end

  def transformed_class_path
    @transformed_class_path ||= begin
      if pluralize_collection?
        class_path[0..-2].append(class_path[-1].pluralize)
      else
        class_path
      end
    end
  end

  def variablefy(val)
    val.to_s.underscore
  end

  def wrap_with_module(content, mod)
    content = indent(content).chomp
    "module #{mod}\n#{content}\nend\n"
  end
end
