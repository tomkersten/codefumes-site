module TextHelper
  # ASSUMPTION: expected output is either 'public' or 'private'
  # NOTE: object specified must have #public? implemented
  def inverted_visibility_of(public_or_private_entity)
    public_or_private_entity.public? ? 'private' : 'public'
  end
end
