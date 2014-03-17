class Voltdb::CriteriaRating < Volter::Model

  # self.table_name = "criteria_ratings"

  def self.alternatives(criterion_ids, alternative_ids=nil, *args)
    criterion_columns = criterion_ids.map{|cr| "cr_#{cr}"}.join(',')
    order_by_columns = criterion_ids.map{|cr| "cr_#{cr} DESC"}.join(',')
    alternative_ids = execute_sql(
      "SELECT alternative_id, #{criterion_columns}
       FROM criteria_ratings 
       #{ !alternative_ids.nil? && "WHERE alternative_id IN ( #{alternative_ids.join(',')} )" }
       ORDER BY #{order_by_columns}"
    ).raw["results"].first["data"][0..19].map{|data| data.first}

    sorted_alternatives = []
    Alternative.where(id: alternative_ids).each do |alternative|
      sorted_alternatives[alternative.id] = alternative
    end

    #TODO: sort by average weight
    return alternative_ids.map{|i| sorted_alternatives[i]}
  end

end