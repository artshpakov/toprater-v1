class Realm

  attr_accessor :id
  attr_accessor :name

  def initialize(id: nil, name:nil)
    @id = id
    @name = name
  end

  class << self

    def all
      %w(hotels restaurants movies).each_with_index.map do |realm, i|
        self.new(id: i+1, name: realm)
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

    def pluck attribute
      all.map { |realm| realm.public_send(attribute) }
    end
  end

  def alternatives
    Alternative.where(realm_id: id)
  end

end
