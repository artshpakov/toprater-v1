class AlternativesIndex < Chewy::Index
  define_type Alternative.includes(:alternatives_criteria, :property_values) do
    field :name
    field :realm_id
    
    Criterion.where.not(ancestry: nil).find_each do |cr|
      field "cr_#{cr.id}".to_sym, 
        value: -> { alternatives_criteria.select {|ac| ac.criterion_id == cr.id}.map(&:rating).first }
    end

    Property::Field.find_each do |prop|
      field "prop_#{prop.id}".to_sym,
        value: -> { property_values.select {|ap| ap.field_id == prop.id}.map(&:value).first }
    end
  end
end
