class Voltdb::Kv < Volter::KeyValueStorage

  self.table_name = "kv"

  def self.get key
    warn "[DEPRECATION] Voltdb::Kv is deprecated. Please use $redis instead."
    ::KV.get key
  end

  def self.set key, val
    warn "[DEPRECATION] Voltdb::Kv is deprecated. Please use $redis instead."
    ::KV.set key, val
  end

  def self.del key
    warn "[DEPRECATION] Voltdb::Kv is deprecated. Please use $redis instead."
    ::KV.del key
  end

end
