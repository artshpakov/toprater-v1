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
  def self.score_by(criteria_ids=[])
    return self.all if criteria_ids.empty?
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

  # Trying to make chewy field type, which doesn't index null fields
  class NotNullField < Chewy::Fields::Default
    def compose(object)
      result = super
      if result.is_a?(Hash) && result.values.first.nil?
        {}
      else
        result
      end
    end
  end

  define_type Alternative.includes(:alternatives_criteria, :property_values) do
    field :name
    field :realm_id, type: 'integer'

    field :location, type: 'geo_point', lat_lon: true, value: -> { lat && lng && [lng, lat] }

    # TODO:
    # FIXME: prop_country_name is bad idea, but it works for now
    expand_nested NotNullField.new(:prop_country_name, type: 'string', value: ->(record) { record.country_name.try(:downcase ) })

    Criterion.rated.find_each do |cr|
      expand_nested NotNullField.new(
        :"cr_#{cr.id}", type: 'double',
        value: -> { alternatives_criteria.select {|ac| ac.criterion_id == cr.id}.first.try(&:corrected_rating) }
      )
    end

    ['boolean', 'integer'].each do |property_type|
      Property::Field.with_types(property_type).find_each do |prop|
        expand_nested NotNullField.new(
          :"prop_#{prop.id}", type: property_type,
          value: -> { property_values.select {|ap| ap.field_id == prop.id}.map(&:casted_value).first }
        )
      end
    end

  end
end
