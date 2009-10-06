module ViewLogicHelper
  def non_paying_user_content(&block)
    yield unless logged_in? && current_user.paying_customer?
  end

  def paying_user_content(&block)
    yield if logged_in? && current_user.paying_customer?
  end

  def priveleged_user_or_owner_content(owned_object = nil, &block)
    return unless logged_in?
    return if owned_object.nil? #until we have a concept of 'admin'
    if owned_object.owner == current_user #|| admin when we have that
      yield
    end
  end
end
