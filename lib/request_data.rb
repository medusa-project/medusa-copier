class RequestData

  FIELDS = %w(source_root source_key target_root target_key)

  attr_accessor *FIELDS

  def initialize(interaction)
    FIELDS.each do |field|
      self.send("#{field}=", interaction.request_parameter(field))
    end
  end

  def valid?
    FIELDS.all {|field| self.send(field)}
  end

  def set_response_data(interaction)
    FIELDS.each do |field|
      interaction.response.set_parameter(field, self.send(field))
    end
  end

  def to_h
    Hash.new.tap do |h|
      FIELDS.each do |field|
        h[field] = self.send(field)
      end
    end
  end

end