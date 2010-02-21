module TextHelper
  # ASSUMPTION: expected output is either 'public' or 'private'
  # NOTE: object specified must have #public? implemented
  def inverted_visibility_of(public_or_private_entity)
    public_or_private_entity.public? ? 'private' : 'public'
  end

  def build_status_class_for(some_entity)
    some_entity.build_status
  end

  def commit_classes_for(commit)
    [commit.merge? ? "merge" : nil, build_status_class_for(commit)].join(" ")
  end
end
