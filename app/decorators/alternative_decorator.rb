class AlternativeDecorator < ApplicationDecorator
  delegate_all

  #def cover_url
    #if object.media.covers.any?
      #object.media.covers.first.url
    #end
  #end

  def score
    ((object.score+1)*20).round if object.score
  end


  def processed_reviews criterion_ids, options={}
    reviews = reviews criterion_ids
    reviews = reviews[0..options[:limit]-1] if options[:limit].present?
    Hash[Array.wrap(criterion_ids).map do |cid|
      [ cid, reviews.select { |rw| rw.criterion_id == cid.to_i } ]
    end]
  end

  def criteria_scores criterion_ids
    reviews = reviews criterion_ids
    Hash[Array.wrap(criterion_ids).map do |cid|
      relevant_reviews = reviews.select { |rw| rw.criterion_id == cid.to_i }
      if relevant_reviews.count > 0
        percentage = relevant_reviews.reduce(0) { |sum, rw| sum + rw.score_percentage } / relevant_reviews.count
        [ cid.to_i, percentage ]
      end
    end]    
  end

  def count_relevant_reviews criterion_ids
    object.review_sentences.where(criterion_id: criterion_ids).count
  end


  protected

  def reviews criterion_ids
    @reviews ||= object.review_sentences.where(criterion_id: criterion_ids)
  end

end
