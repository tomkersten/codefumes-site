class PayloadProcessor
  def self.process!(payload)
    project = payload.project
    content = payload.content

    # TODO: Clean this code up
    for commit_params in content["commits"] do
      normalized_commit_params = Commit.normalize_params(commit_params)
      commit = Commit.find_by_identifier(normalized_commit_params["identifier"])
      if commit
        commit.update_attributes(normalized_commit_params)
      else
        commit = Commit.create!(normalized_commit_params) # fails fast
      end
      project.commits << commit unless project.commits.include?(commit)
    end
  rescue => exception
    RAILS_DEFAULT_LOGGER.error "Error processing Payload!"
    RAILS_DEFAULT_LOGGER.error "\tPayload ID: #{payload.id}"
    RAILS_DEFAULT_LOGGER.error "\tProject: #{payload.project.public_key} (ID: #{payload.project.id})"
    RAILS_DEFAULT_LOGGER.error "########## Backtrace:"
    RAILS_DEFAULT_LOGGER.error exception.backtrace
    RAILS_DEFAULT_LOGGER.error "########## End of backtrace"
    raise exception
  end
end
