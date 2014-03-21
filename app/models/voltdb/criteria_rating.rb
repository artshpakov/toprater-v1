class Voltdb::CriteriaRating < Volter::Model

  # self.table_name = "criteria_ratings"

  def self.alternatives(criterion_ids, alternatives_ids=nil, *args)
    criterion_columns = criterion_ids.map{|cr| "cr_#{cr}"}

    result = execute_sql(
      "SELECT alternative_id, CAST((#{criterion_columns.map{|cr| "COALESCE(#{cr}, 0)" }.join('+')}) AS FLOAT)/#{criterion_columns.size} AS score
       FROM criteria_ratings 
       #{ "WHERE alternative_id IN ( #{alternatives_ids.join(',')} )" if !alternatives_ids.nil? }
       ORDER BY score DESC LIMIT 20"

    ).raw["results"].first["data"][0..19]

    alternatives_scores = result.map{|data| {data[0] => data[1]} }.reduce Hash.new, :merge
    sorted_alternatives = []

    Alternative.where(id: alternatives_scores.keys).each do |alternative|
      alternative.avg_score = alternatives_scores[alternative.id]
      sorted_alternatives[alternative.id] = alternative
    end

    return alternatives_scores.keys.map{|i| sorted_alternatives[i]}
  end

end
