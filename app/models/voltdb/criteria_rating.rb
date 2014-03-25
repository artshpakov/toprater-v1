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
      @conditions ||= {}
      @conditions.merge!(opts)
      self
    end

    def limit(limit)
      @limit = limit
      self
    end

    def score_by(opts)
      @score_by = opts || []
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
          @sql[:froms] << "criteria_ratings cr"
        else
          @sql[:joins] << "LEFT JOIN criteria_ratings cr ON cr.alternative_id = ap.alternative_id"
        end
        @sql[:orders] << "score DESC"
      end

      if @sql[:selects].empty? or @sql[:froms].empty?
        alternatives = Alternative.all
        alternatives = alternatives.limit(@sql[:limit]) unless @sql[:limit].empty?
        alternatives = alternatives.count unless @sql[:count].empty?
        return alternatives
      end

      sql = "SELECT #{ @sql[:selects].join(', ')} FROM #{@sql[:froms].join(',')} #{@sql[:joins].join(',')} #{ "WHERE #{@sql[:wheres].join(',')}" if @sql[:wheres].present?} #{"ORDER BY #{@sql[:orders].join(',')}" if @sql[:orders].present?} #{"LIMIT #{@sql[:limit]}" if @sql[:limit].present?}"

      result = execute_sql(sql).raw["results"].first["data"]

      if @columns.include? :alternative_id
        i = @columns.index :alternative_id
        alternative_ids = result.map{|row| row[i]}
        alternatives = Alternative.where(id: alternative_ids)

        sorted_alternatives = []
        alternatives.each do |a|
          sorted_alternatives[a.id] = a
        end

        output = result.map{|row| OpenStruct.new(Hash[@columns.zip(row)].merge(object: sorted_alternatives[row[i]]))}
      else
        output = result.map{|row| OpenStruct.new(Hash[@columns.zip(row)])}
      end
 
    end

    def count
      @count = "*"
      self
    end

  end

end
