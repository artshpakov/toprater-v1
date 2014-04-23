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

  def reviews options={}
    @st ||= object.review_sentences.where(criterion_id: criterion_ids)
    if options[:limit].try(:to_i) then @st[0..options[:limit].to_i-1] else @st end
  end


  def processed_reviews criterion_ids
    Hash[Array.wrap(criterion_ids).map do |cid|
      [ cid, reviews.select { |rw| rw.criterion_id == cid.to_i }.map {|rw| { rating: calculate_score(rw.score), sentences: rw.sentences }} ]
    end]
  end

  def criteria_scores criterion_ids
    Hash[Array.wrap(criterion_ids).map do |cid|
      relevant_reviews = reviews.select { |rw| rw.criterion_id == cid.to_i }
      if relevant_reviews.count > 0
        score = relevant_reviews.reduce(0) { |sum, rw| sum + rw.score } / relevant_reviews.count
        [ cid.to_i, calculate_percentage(score) ]
      end
    end]    
  end

  def count_relevant_reviews criterion_ids
    object.review_sentences.where(criterion_id: criterion_ids).count
  end


  protected

  def calculate_score value
    (value + 1) * 2.5
  end

  def calculate_percentage value
    (value + 1) * 50
  end

end
