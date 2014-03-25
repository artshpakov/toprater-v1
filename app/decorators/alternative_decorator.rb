class AlternativeDecorator < ApplicationDecorator
  delegate_all

  def link_to_lmgtfy
    h.link_to(object.name, "http://lmgtfy.com/?q=#{object.name.gsub(' ', '+')}", target: '_blank').html_safe
  end

  def processed_reviews criterion_ids
    reviews = object.review_sentences.where(criterion_id: criterion_ids)
    Hash[Array.wrap(criterion_ids).map do |cid|
      [ cid, reviews.select { |rw| rw.criterion_id == cid.to_i }.map {|rw| { rating: rw.score, sentences: rw.sentences }} ]
    end]
  end

  def count_relevant_reviews criterion_ids
    object.review_sentences.where(criterion_id: criterion_ids).count
  end
end
