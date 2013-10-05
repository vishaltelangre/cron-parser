module StringExtensions
  def ordinalize
    unless !!(/\A\d+\Z|\A\d+\.\d+\Z/ =~ self)
      raise NameError.new "cannot ordinalize non-numeric value"
    end

    "#{self}#{self.ordinal}"
  end

  def ordinal
    ActiveSupport::Inflector.ordinal(self)
  end

  def squish
    dup.squish!
  end

  def squish!
    strip!
    gsub!(/\s+/, ' ')
    self
  end
end

class String; self.send :include, StringExtensions end

class Object
  # Generate hex value for requester object in argument
  def self.o_hexy_id(requester) # that's not "oh sexy lady", or is it?!
    "0x" + (requester.object_id << 1).to_s(16)
  end
end
