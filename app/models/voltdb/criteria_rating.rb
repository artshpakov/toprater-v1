class Voltdb::CriteriaRating < Volter::Model

  self.table_name = "criteria_ratings"

  class << self

    def select
      instance_variables.each do |var|
        remove_instance_variable var unless [:@table_name].include? var
      end
      self
    end

    def where(opts)
      @conditions ||= {}
      if opts.is_a? Hash
        opts.each do |key, val|
          if @conditions[key].present?
            @conditions[key].merge! val
          else
            @conditions[key] = val
          end
        end
      end
      self
    end

    def limit(limit)
      @limit = limit
      self
    end

    def score_by(opts)
      @score_by = opts || []
      @score_by = [@score_by] unless @score_by.is_a? Array
      self
    end

    def ids
      @ids_only = true
      self
    end

    def load
      @sql = {selects: [], froms: [], joins: [], wheres: [], orders: [], limit: "", count: ""}
      @columns = []

      if @conditions and @conditions[:properties]
        properties = @conditions[:properties].symbolize_keys
        prop_columns = properties.keys.map{|prop| "ap.prop_#{prop}"}
        @sql[:selects] << "ap.alternative_id"
        @columns << :alternative_id
        @sql[:selects] += prop_columns
        @columns += properties.keys.map{|prop| :"prop_#{prop}"}

        @sql[:froms] << "alternatives_properties ap"
        @sql[:wheres] << properties.map{|prop, val| "ap.prop_#{prop}=#{val}"}.join(" AND ")

        if @count
          @sql[:selects] = ["COUNT(#{@count})"]
          @columns = [:count]
        end
      end

      if @limit
        @sql[:limit] = @limit.to_s
      end

      if @score_by and @score_by.any?
        criterion_columns = @score_by.map{|cr| "cr.cr_#{cr}"}
        if @sql[:selects].empty?
          @sql[:selects] << "cr.alternative_id"
          @columns = [:alternative_id]
        end
        @sql[:selects] << "CAST((#{criterion_columns.map{|cr| "COALESCE(#{cr}, 0)" }.join('+')}) AS FLOAT)/#{criterion_columns.size} AS score"
        @columns << :score

        if @sql[:froms].empty?
          @sql[:froms] << "#{@table_name} cr"
        else
          @sql[:joins] << "LEFT JOIN #{@table_name} cr ON cr.alternative_id = ap.alternative_id"
        end
        @sql[:orders] << "score DESC"
      end

      if @sql[:selects].empty? or @sql[:froms].empty?
        alternatives = Alternative.all
        alternatives = alternatives.limit(@limit) if @limit and @limit.present?
        alternatives = alternatives.count if @count and @count.present?
        return alternatives
      end

      sql = "SELECT #{ @sql[:selects].join(', ')} FROM #{@sql[:froms].join(',')} #{@sql[:joins].join(',')} #{ "WHERE #{@sql[:wheres].join(',')}" if @sql[:wheres].present?} #{"ORDER BY #{@sql[:orders].join(',')}" if @sql[:orders].present?} #{"LIMIT #{@sql[:limit]}" if @sql[:limit].present?}"

      result = execute_sql(sql).raw["results"].first["data"]

      if @columns.include? :count
        return result[0][0]
      end

      if @columns.include? :alternative_id
        alternative_id_index = @columns.index :alternative_id
        alternative_ids = result.map{|row| row[alternative_id_index]}

        return alternative_ids if @ids_only

        scores = result.map{|row| {row[alternative_id_index] => row[@columns.index(:score)]}}.reduce Hash.new, :merge if @columns.include? :score
        alternatives = Alternative.where(id: alternative_ids)

        sorted_alternatives = []
        alternatives.each do |a|
          a.score = scores[a.id] if @columns.include? :score
          sorted_alternatives[alternative_ids.index(a.id)] = a
        end

        return sorted_alternatives
      end

      nil
 
    end

    def count
      @count = "*"
      self
    end

  end

end
