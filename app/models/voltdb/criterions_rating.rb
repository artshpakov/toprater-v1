class Voltdb::CriterionsRating < Volter::Model

  # self.table_name = "criteria_ratings"

  def self.alternatives(alternative_ids, criterion_ids, *args)


    criterion_columns = criterion_ids.map{|cr| "cr_#{cr}"}.join(',')
    order_by_columns = criterion_ids.map{|cr| "cr_#{cr} DESC"}.join(',')

    result = execute_sql(
      "SELECT alternative_id, #{criterion_columns}
       FROM criteria_ratings 
       WHERE alternative_id IN ( #{alternative_ids.join(',')} )
       ORDER BY #{order_by_columns}"
    )

    alternative_ids = result.raw["results"].first["data"][0..19].map{|data| data.first}

    sorted_alternatives = []
    Alternative.where(id: alternative_ids).each do |alternative|
      sorted_alternatives[alternative.id] = alternative
    end

    #TODO: sort by average weight
    return alternative_ids.map{|i| sorted_alternatives[i]}

  end

end
