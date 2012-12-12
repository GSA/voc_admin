# Generates random passwords.
module PasswordGenerator

  # Generates a random password with specified size, containing the
  # specified number of special characters, numbers, capital and lower case.
  #
  # @param [Integer] num_lower number of lowercase characters
  # @param [Integer] num_capitals number of uppercase characters
  # @param [Integer] num_numbers number of numbers characters
  # @param [Integer] num_special number of special characters
  # @return [String] a generated random password
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

  # Generates a specified number of lower case characters.
  #
  # @param [Integer] total the number of characters to generate
  # @return [String] the generated characters
  def self.get_lowercase(total)
    source = ("a".."z").to_a
    ret = get_from_array(total, source)
    ret
  end

  # Generates a specified number of upper case characters.
  #
  # @param [Integer] total the number of characters to generate
  # @return [String] the generated characters
  def self.get_capitals(total)
    ret = get_lowercase(total)
    ret.upcase
  end

  # Generates a specified number of numeric characters.
  #
  # @param [Integer] total the number of characters to generate
  # @return [String] the generated characters
  def self.get_numbers(total)
    source = ("0".."9").to_a
    ret = get_from_array(total, source)
    ret
  end

  # Generates a specified number of special characters from: !@#$%^&*
  #
  # @param [Integer] total the number of characters to generate
  # @return [String] the generated characters
  def self.get_special(total)
    source = ['!','@','#','$','%','^','&','*']
    ret = get_from_array(total, source)
    ret
  end

  # Assembles a string of randomly-chosen characters from a source
  # and a specified length.
  #
  # @param [Integer] total the number of characters to generate
  # @param [Array] source the Array to choose characters from
  # @return [String] the assembled string of characters
  def self.get_from_array(total, source)
    ret = ""
    1.upto(total) { |i| ret << source[rand(source.size-1)] }
    ret
  end
end