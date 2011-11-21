module PasswordGenerator
  #generates a random password with specified size, containing the specified number of special characters, numbers, capital and lower case
  def self.generate_password(num_lower, num_capitals=0, num_numbers=0, num_special=0)
    ret = ""
    ret += get_lowercase(num_lower)
    ret += get_capitals(num_capitals)
    ret += get_numbers(num_numbers)
    ret += get_special(num_special)

    ret = ret.split("").sort_by{rand}.join()
    ret
  end
  
  private
  #returns specified number of lower case characters
  def self.get_lowercase(total)
    source = ("a".."z").to_a
    ret = get_from_array(total, source)
    ret
  end
  
  #returns specified number of upper case characters
  def self.get_capitals(total)
    ret = get_lowercase(total)
    ret.upcase
  end
  
  #returns specified number of number as string
  def self.get_numbers(total)
    source = ("0".."9").to_a
    ret = get_from_array(total, source)
    ret
  end
  
  #returns specified number of special characters
  #Possible values: !@#$%^&*
  def self.get_special(total)
    source = ['!','@','#','$','%','^','&','*']
    ret = get_from_array(total, source)
    ret
  end
  
  def self.get_from_array(total, source)
    ret = ""
    1.upto(total) { |i| ret << source[rand(source.size-1)] }
    ret
  end
  
end