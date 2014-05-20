class Property::Value < ActiveRecord::Base

  belongs_to :alternative
  belongs_to :field

  def casted_value
    case field.field_type
    when 'integer'
      value.to_i
    when 'boolean'
      value.to_i == 1 ? true : false
    else
      value
    end
  end

end
