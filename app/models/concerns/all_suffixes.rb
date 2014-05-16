module AllSuffixes

private

  # "foo bar baz" => ["foo bar baz", "bar baz", "baz"]
  def all_suffixes(string)
    words = string.split
    (0...words.size).map {|idx| words[idx..-1].join(" ") }
  end
end
