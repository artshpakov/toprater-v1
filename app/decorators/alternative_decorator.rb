class AlternativeDecorator < ApplicationDecorator
  delegate_all

  def name
    h.link_to(object.name, "http://lmgtfy.com/?q=#{object.name.gsub(' ', '+')}", target: '_blank').html_safe
  end
end
