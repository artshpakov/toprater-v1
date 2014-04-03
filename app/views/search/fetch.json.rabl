collection @results
attributes :id, :name
node :type do |tip|
  tip.class.name.downcase.split("::").first
end
