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

  def self.complete(text, size: 5, correct: false)
    fuzziness = correct ? {fuzzy: { edit_distance: 1, min_length: 4}} : {}
    client.suggest(
      index: 'complete',
      body: {
        results: {
          text: text,
          completion: {
            field: "suggest",
            size: size,
          }.merge(fuzziness)
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

  def self.complete_loaded_with_corrections(text, size: 5)
    results = complete_loaded(text, size: size)
    if results.size < size
      results += complete_loaded(text, size: size, correct: true)
      results = results.uniq[0...size]
    end
    results
  end

  define_type Realm do

    def self.import(*args)
      args.unshift ::Realm.all if args.blank? || args[0].is_a?(Hash)
      super *args
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

  define_type Criterion.rated do
    field :name
    field :suggest, type: 'completion', payloads: true, value: -> {{
      weight: 2,
      output: name,
      input: all_suffixes(name),
      payload: { type: 'criterion', id: id }
    }}
  end

  define_type Property::Field, name: 'fields' do
    field :name
    field :suggest, type: 'completion', payloads: true, value: -> {{
      weight: 2,
      output: name,
      input: all_suffixes(name),
      payload: { type: 'field', id: id }
    }}
  end

end
