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

  def self.complete(text, size: 5)
    client.suggest(
      index: 'complete',
      body: {
        results: {
          text: text,
          completion: {
            field: "suggest",
            size: size,
            fuzzy: { edit_distance: 2, min_length: 4}
          }
        }
      }
    )
  end

  # FIXME batch-load objects from same tables, if we stick with the implementation
  def self.complete_loaded(*args)
    results = complete(*args)["results"][0]["options"]
    results.map do |o|
      case o["payload"]["type"]
      when "realm";       ::Realm
      when "alternative"; ::Alternative
      when "criterion";   ::Criterion
      when "field";       ::Property::Field
      end.find( o["payload"]["id"] )
    end
  end

  define_type Realm do

    def self.import(*args)
      args = ::Realm.all if args.blank?
      super args
    end

    field :name
    field :suggest, type: 'completion', payloads: true, value: -> {{
      weight: 3,
      output: name,
      input: [name],
      payload: { type: 'realm', id: id }
    }}
  end

  define_type Alternative do
    field :name
    field :realm_id
    field :suggest, type: 'completion', payloads: true, value: -> {{
      weight: 1,
      output: name,
      input: [name],
      payload: { type: 'alternative', id: id }
    }}
  end

  define_type Criterion do
    field :name
    field :suggest, type: 'completion', payloads: true, value: -> {{
      weight: 2,
      output: name,
      input: [name],
      payload: { type: 'criterion', id: id }
    }}
  end

  define_type Property::Field, name: 'fields' do
    field :name
    field :suggest, type: 'completion', payloads: true, value: -> {{
      weight: 2,
      output: name,
      input: [name],
      payload: { type: 'field', id: id }
    }}
  end

end
