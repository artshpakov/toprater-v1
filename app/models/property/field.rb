class Property::Field < ActiveRecord::Base
  belongs_to :group
  has_many :values

  def voltdb_type
    case field_type
      when 'boolean'
        'TINYINT'
      when 'integer'
        'INTEGER'
      when 'string'
        'VARCHAR(255)'
      when 'text'
        'VARCHAR(255)'
      when 'datetime'
        'TIMESTAMP'
      else
        'VARCHAR(255)'
    end
  end
end
