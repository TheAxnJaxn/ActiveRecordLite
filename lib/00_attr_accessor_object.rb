class AttrAccessorObject
  def self.my_attr_accessor(*names)
    # defines setter/getter methods
    names.each do |name|
      # method names are the names of the instance variables you're
      # getting/setting, so this can be used across many instance variables
      define_method("#{name}") { instance_variable_get("@#{name}") }

      define_method("#{name}=") do |thing|
        instance_variable_set("@#{name}", thing)
      end
    end
  end
end
