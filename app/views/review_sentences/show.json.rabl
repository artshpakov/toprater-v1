object @sentence
attributes :id, :sentences, :score, :percentage
node(:agency_name) { |s| s.review.class.agency_name }
node(:agency_url) { |s| s.review.class.agency_url }
