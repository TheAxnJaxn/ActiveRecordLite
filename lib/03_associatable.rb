require_relative '02_searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  # goes from class name to class object
  def model_class
    @class_name.constantize
  end

  # gives the name of the table using Class::table_name
  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions

  # provides default values for the three important attributes
  def initialize(name, options = {})

    defaults = { :primary_key => :id,
          :class_name => name.to_s.camelcase,
          :foreign_key => "#{name}_id".to_sym}

    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end
end

class HasManyOptions < AssocOptions

  # provides default values for the three important attributes
  def initialize(name, self_class_name, options = {})

    defaults = { :primary_key => :id,
          :class_name => name.to_s.singularize.camelcase,
          :foreign_key => "#{self_class_name.underscore}_id".to_sym}

    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end
end

module Associatable

  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)

    # creates new method to access the association
    define_method(name) do
      options = self.class.assoc_options[name]
      key_val = self.send(options.foreign_key)
      options.model_class.where(options.primary_key => key_val).first
    end
  end

  def has_many(name, options = {})
    self.assoc_options[name] = HasManyOptions.new(name, self.name, options)

    # creates new method to access the association
    define_method(name) do
      options = self.class.assoc_options[name]
      key_val = self.send(options.primary_key)
      options.model_class.where(options.foreign_key => key_val)
    end
  end

  def assoc_options
    @assoc_options ||= {}
    @assoc_options
  end
end

class SQLObject
  # Mixes in Associatable
  extend Associatable
end
