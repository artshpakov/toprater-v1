class AlternativeDecorator < ApplicationDecorator
  delegate_all

  def link_to_lmgtfy
    h.link_to(object.name, "http://lmgtfy.com/?q=#{object.name.gsub(' ', '+')}", target: '_blank').html_safe
  end

  def avg_score
    if object.avg_score
      (object.avg_score*100/5).round
    end
  end
end
