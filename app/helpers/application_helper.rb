module ApplicationHelper
  def ie?
    m = /MSIE\s+([0-9, \.]+)/.match(request.user_agent)
    unless m.nil?
      m[1].to_f
    end
  end

  def priveleged_user_or_owner_content(owned_object = nil, &block)
    return false unless logged_in?
    return false if owned_object.nil? #until we have a concept of 'admin'
    if owned_object.owner == current_user #|| admin when we have that
      yield
    end
  end
end
