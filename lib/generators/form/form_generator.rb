# frozen_string_literal: true

require 'rails/generators/named_base'

class FormGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)
  # check_class_collision

  def generate_form
    template 'form.rb', File.join('app/lib/forms', class_path, "#{file_name}.rb")
  end

  def generate_form_spec
    template 'form_spec.rb', File.join('spec/lib/forms', class_path, "#{file_name}_spec.rb")
  end

  private

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

  def wrap_with_module(content, mod)
    content = indent(content).chomp
    "module #{mod}\n#{content}\nend\n"
  end
end
