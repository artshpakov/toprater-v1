class Voltdb::CriterionsRating < Volter::Model

  def alternatives(alternative_ids, criterion_ids, *args)

    criterion_columns = criterion_ids.map{|cr| "criterion_#{cr}"}.join(',')

    result = execute_sql(
      "SELECT alternative_id, #{criterion_columns}
       FROM criterion_ratings 
       WHERE alternative_id IN ( #{alternative_ids.join(',')} )
       ORDER BY #{criterion_columns} DESC"
    )

    # result - sorted list of alternatives

  end

end
