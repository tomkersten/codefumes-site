class PayloadProcessor
  def self.process!(payload)
    project = payload.project
    content = payload.content
    for commit_params in content["commits"] do
      project.commits << Commit.create(commit_params)
    end
  end
end
