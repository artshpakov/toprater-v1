collection alternatives
attributes :id, :name, :score, :cover_url
node :top do |alternative|
  alternative.top.map { |id, grade| { id: id.to_i, grade: grade } }
end
node(:realm) { "hotels" }
