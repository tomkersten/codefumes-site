module TextHelper
  def build_duration_text_for(buildable)
    return if buildable.average_build_duration == 0

    minutes, seconds = buildable.average_build_duration.divmod(60.0)

    haml_tag :span, :class => "duration" do
      haml_concat "#{minutes}min #{seconds.round}secs"
    end
  end



  # ASSUMPTION: expected output is either 'public' or 'private'
  # NOTE: object specified must have #public? implemented
  def inverted_visibility_of(public_or_private_entity)
    public_or_private_entity.public? ? 'private' : 'public'
  end

  def build_status_class_for(some_entity)
    some_entity.is_a?(Build) ? some_entity.state : some_entity.build_status
  end

  def commit_classes_for(commit)
    commit && commit.merge? ? "merge" : ''
  end
end
