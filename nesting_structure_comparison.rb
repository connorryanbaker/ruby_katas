#https://www.codewars.com/kata/nesting-structure-comparison
class Array
  def same_structure_as(arr)
    return false if arr.class != Array
    self.each_index do |idx|
      if self[idx].class != arr[idx].class
        return false if self[idx].is_a?(Array) || arr[idx].is_a?(Array)
      elsif self[idx].is_a?(Array)
        if self[idx].length == arr[idx].length
          return self[idx].same_structure_as(arr[idx])
        else
          return false
        end
      end
    end
    true
  end
end
