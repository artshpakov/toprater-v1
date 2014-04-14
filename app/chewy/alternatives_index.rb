class AlternativesIndex < Chewy::Index
  define_type Alternative.includes(:alternatives_criteria, :property_values) do
    field :name
    field :realm_id, type: 'integer'

    # FIXME get rid of "null" values in indexed documents.
    Criterion.where.not(ancestry: nil).find_each do |cr|
      field :"cr_#{cr.id}", type: 'double',
        value: -> { alternatives_criteria.select {|ac| ac.criterion_id == cr.id}.map(&:rating).first }
    end

    Property::Field.find_each do |prop|
      field :"prop_#{prop.id}", type: 'boolean',
        value: -> { property_values.select {|ap| ap.field_id == prop.id}.map(&:value).first }
    end
  end
end
