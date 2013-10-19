module StringExtensions
  # Adds 'th', 'nd', 'st' like ordinal to numerical (string) values.
  # e.g. 22nd, 40th, 1st etc.
  def ordinalize
    match = /\A(?<int>\d+)\Z|\A(?<real>\d+\.\d+)\Z/.match(self)
    raise NameError.new("cannot ordinalize non-numeric value") unless match
    num = match[:int] ? self.to_i : self.to_f
    "#{num}#{num.to_s.ordinal}"
  end

  def ordinal
    ActiveSupport::Inflector.ordinal(self)
  end

  # Removes extra whitespaces from the string.
  def squish
    dup.squish!
  end

  # Destructive version of `squish` method.
  def squish!
    strip!
    gsub!(/\s+/, ' ')
    self
  end
end

class String; self.send :include, StringExtensions end

class Object
  # Generate hex value for requester object in argument.
  def self.o_hexy_id(requester) # that's not "oh sexy lady", or is it?!
    "0x" + (requester.object_id << 1).to_s(16)
  end
end