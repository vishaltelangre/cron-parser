module StringExtensions
  def ordinalize
    unless !!(/\A\d+\Z|\A\d+\.\d+\Z/ =~ self)
      raise NameError.new "cannot ordinalize non-numeric value"
    end

    "#{self}#{self.ordinal}"
  end

  def ordinal
    abs_number = self.to_i.abs

    if (11..13).include?(abs_number % 100)
      "th"
    else
      case abs_number % 10
      when 1; "st"
      when 2; "nd"
      when 3; "rd"
      else    "th"
      end
    end
  end

  def squish
    dup.squish!
  end

  def squish!
    strip!
    gsub!(/\s+/, ' ')
    self
  end

  def humanize
   gsub(/_/, ' ').capitalize
  end
end

class String; self.send :include, StringExtensions end
