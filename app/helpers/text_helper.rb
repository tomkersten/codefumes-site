module TextHelper
  def avg_build_duration_text_for(commit)
    return if commit.average_build_duration == 0

    minutes, seconds = commit.average_build_duration.divmod(60.0)

    haml_tag :span, :class => :duration do
      haml_concat "#{minutes}min #{seconds.round}secs"
    end
  end

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
