class CompleteIndex < Chewy::Index

  #settings analysis: {
    #analyzer: {
      #title: {
        #tokenizer: 'standard',
        #filter: ['lowercase', 'asciifolding']
      #}
    #}
  #}
  
  define_type Alternative.includes(:alternatives_criteria, :property_values) do
    field :name # , index: 'analyzed', analyzer: 'title'
    field :realm_id
    #field :criteria, type: 'object', value: ->{ alternatives_criteria.to_a } do
      #field :name, value: ->(ac) { ac.criterion.name }
      #field :rating, type: 'integer', value: ->(ac) { ac.rating }
    #end
    #field :properties, type: 'object', value: ->{ property_values.to_a } do
      #field :name, value: ->(ap) { ap.field.name }
      #field :value, value: ->(ap) { ap.value }
    #end
  end

  define_type Criterion do
    field :name
  end

  define_type Property::Field, name: 'fields' do
    field :name
  end

end
