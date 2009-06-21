class PayloadProcessor
  def self.process!(payload)
    project = payload.project
    content = payload.content

    # TODO: Clean this code up
    for commit_params in content["commits"] do
      commit = Commit.find_by_identifier(commit_params["identifier"])
      if commit
        commit.update_attributes(commit_params)
      else
        commit = Commit.create!(commit_params) # fails fast
      end
      project.commits << commit unless project.commits.include?(commit)
    end
  rescue => exception
    puts "Error processing Payload!"
    puts "\tPayload ID: #{payload.id}"
    puts "\tProject: #{payload.project.public_key} (ID: #{payload.project.id})"
    puts "########## Backtrace:"
    puts exception.backtrace
    puts "########## End of backtrace"
    raise exception
  end
end
