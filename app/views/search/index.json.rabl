collection @results
attributes :id, :name
node :type do |tip|
  tip.class.name.downcase.split("::").first
end
node :realm do |tip|
  # tip.realm.name if tip.respond_to?(:realm) and tip.realm
  Realm.first.name
end
