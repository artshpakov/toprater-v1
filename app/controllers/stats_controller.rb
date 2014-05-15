class StatsController < ApplicationController
  def index
    render content_type: 'text/plain', text: <<-"END"
      Alternative:              #{Alternative.count}
      Criterion:                #{Criterion.count}
      AlternativesCriterion:    #{AlternativesCriterion.count}
      Medium:                   #{Medium.count}
      Review:                   #{Review.count}
      ReviewSentence:           #{ReviewSentence.count}
      Review::Tripadvisor:      #{Review::Tripadvisor.count}
      Property::Field:          #{Property::Field.count}
      Property::Group:          #{Property::Group.count}
      Property::Value:          #{Property::Value.count}
    END
  end
end
