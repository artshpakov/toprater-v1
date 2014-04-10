class Realm < Struct.new(:id, :name)

  class << self

    def all
      %w(Hotel Restaurant Movie).each_with_index.map do |realm, i|
        self.new(i+1, realm)
      end
    end

    def find id
      all.select{|realm| realm.id == id}.first
    end

    def where opts
      fields = opts.keys
      all.select { |realm| fields.any? {|field| realm[field] == opts[field]} }
    end

    def first
      all.first
    end
  end

  def alternatives
    Alternative.where(realm_id: id)
  end

end
