class Voltdb::CriteriaRating < Volter::Model

  # self.table_name = "criteria_ratings"

  class << self

    def select
      instance_variables.each do |var|
        remove_instance_variable var
      end
      self
    end

    def where(opts)
      @alternative_id = opts[:alternative_id].to_a if opts[:alternative_id]
      @criterion_id = opts[:criterion_id].to_a if opts[:criterion_id]
      self
    end

    def limit(limit)
      @limit = limit
      self
    end

    def order(criterion_ids)
      criterion_columns = criterion_ids.map{|cr| "cr_#{cr}"}

      result = execute_sql(
        "SELECT alternative_id, CAST((#{criterion_columns.map{|cr| "COALESCE(#{cr}, 0)" }.join('+')}) AS FLOAT)/#{criterion_columns.size} AS score
         FROM criteria_ratings 
         #{ "WHERE alternative_id IN ( #{@alternative_id.join(',')} )" if defined?(@alternative_id) and !@alternative_id.nil? }
         ORDER BY score DESC LIMIT #{ defined?(@limit) ? @limit : 20 }"

      ).raw["results"].first["data"][0..19]

      @scores = result.map{|data| {data[0] => data[1]} }.reduce(Hash.new, :merge)
      @alternative_id = @scores.keys unless defined? @alternative_id
      self
    end

    def first
      if defined? @alternative_id
        if defined? @scores
          alternative = Alternative.where(id: @scores.keys.first).first
          if alternative
            alternative.avg_score = @scores.values.first
            return alternative
          else
            return nil
          end
        else
          return Alternative.where(id: @alternative_id.first).first
        end
      end
      Alternative.first
    end

    def count
      return @alternative_id.length if defined? @alternative_id
      Alternative.count
    end

    def load
      alternatives = []

      if defined? @alternative_id
        alternatives = Alternative.where(id: @alternative_id)
      end

      if defined? @scores
        sorted_alternatives = []
        alternatives.each do |alternative|
          alternative.avg_score = @scores[alternative.id]
          sorted_alternatives[alternative.id] = alternative
        end
        return @scores.keys.map{|i| sorted_alternatives[i]}
      end
      alternatives
    end

    def ids
      @alternative_id if defined? @alternative_id
    end


  end

end



    #@alternative_ids = opts[:alternative_ids] || []
    #@scores = opts[:scores] || {}
