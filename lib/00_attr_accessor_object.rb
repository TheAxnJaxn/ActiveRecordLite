class AttrAccessorObject
  def self.my_attr_accessor(*names)
    # it should define setter/getter methods
    # use define_method with instance_variable_set and
    # instance_variable_get to define getter and setter instance methods
    names.each do |name|

      define_method("#{name}") { instance_variable_get("@#{name}") }

      define_method("#{name}=") do |thing|
        instance_variable_set("@#{name}", thing)
      end

    end
  end

  # Note to self: pay attention to the define_method - what do you
  # want your name to be? Not "get" or "set", but instead the
  # name of the instance variable you're getting/setting.
end
