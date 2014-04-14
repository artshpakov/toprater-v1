class AlternativesIndex < Chewy::Index

  # curl 'localhost:9200/alternatives/_search/?format=yaml&_source=0' -d '
  # {"query": {
  #   "function_score": {
  #     "functions": [
  #       { "script_score": { "script": "doc[cr].value", "params": { "cr": "cr_506" } } },
  #       { "script_score": { "script": "doc[cr].value", "params": { "cr": "cr_507" } } }
  #     ],
  #     "score_mode": "avg",
  #     "boost_mode": "replace"
  #     }
  #   }
  # }}'

  # TODO replace script_score with field_value_factor, introduced in ES 1.2
  def self.weighted(criteria_ids=[])
    return self if criteria_ids.empty?
    script = "doc[cr].value"
    query(
      function_score: {
        functions: criteria_ids.map { |cr_id|
          { script_score: { script: script, params: {cr: "cr_#{cr_id}"} } }
        },
        score_mode: 'avg',
        boost_mode: 'replace'
      }
    )
  end

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
