class CompleteIndex < Chewy::Index

  # curl -X POST http://localhost:9200/complete/_suggest -d '
  # {
  #   "doesntmatter?": {
  #     "text" : "user que",
  #     "completion" : {
  #       "field" : "suggest",
  #       "fuzzy" : { "edit_distance" : 2 }
  #     }
  #   }
  # }'

  define_type Realm do
    field :suggest, type: 'completion', payloads: true, value: -> { name }
  end

  define_type Alternative do
    field :name
    field :realm_id
    field :suggest, type: 'completion', payloads: true, value: -> { name }
  end

  define_type Criterion do
    field :name
    field :suggest, type: 'completion', payloads: true, value: -> { name }
  end

  define_type Property::Field, name: 'fields' do
    field :name
    field :suggest, type: 'completion', payloads: true, value: -> { name }
  end

end
