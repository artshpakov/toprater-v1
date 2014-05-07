module AllSuffixes

private

  # "foo bar baz" => ["foo bar baz", "bar baz", "baz"]
  def all_suffixes(string)
    string.scan(/(?:^|\s)(?=(\S.*))/).flatten
  end
end
