class LeetClass
  attr_accessor :classes
  def initialize
    @classes = Array.new
  end

  def create_classes
    1337.times do |i|
      name = "C".concat(i.to_s)
      Object.const_set(name, Class.new)
      new_class = eval("#{name}")
      new_class.singleton_class.class_eval do 
        method_name = name 
        define_method(method_name) do
          puts method_name + "cm"
        end 
      end 
      im_name = name + "im"
      new_class.instance_eval do
        define_method im_name do
          im_name
        end 
      end 
      @classes << new_class
    end
    @classes
  end
end

def leet_classes
  LeetClass.new.create_classes
end

arr = leet_classes
p arr[0].methods(false)
