require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Api::V1::CommitsController do
  before(:each) do
    @request.env["HTTP_ACCEPT"] = "application/xml"
  end

  shared_examples_for "Any valid GET request to a specific commit" do
    it "returns a status code of '200 OK'" do
      perform_request
      response.status.should == '200 OK'
    end

    it "renders the 'show' view template" do
      perform_request
      response.should render_template('api/v1/commits/show')
    end

    it "sets the Location header to the API URI of the commit loaded for the view template" do
      perform_request
      response.headers['Location'].should == api_v1_commit_url(@commit)
    end
  end

  describe "a GET to index" do
    before(:each) do
      @project = Project.make
      @project_commits = 3.times.map {Commit.make}
      @project.commits << @project_commits
      extra_commits = 4.times.map {Commit.make}
    end

    def perform_request
      get :index, :project_id => @project.public_key
    end

    context "a valid request" do
      it "returns a status code of '200 OK'" do
        perform_request
        response.status.should == '200 OK'
      end

      it "renders the 'index' view" do
        perform_request
        response.should render_template('api/v1/commits/index')
      end

      it "assigns a list of all the specified project's commits" do
        perform_request
        assigns[:commits].should == @project_commits
      end
    end
  end

  describe "a GET to show" do
    before(:each) do
      @project = Project.make
      @commit = Commit.make
      @project.commits << @commit
    end

    def perform_request
      get :show, :project_id => @project.public_key, :id => @commit.identifier
    end

    context "a valid request" do
      it_should_behave_like "Any valid GET request to a specific commit"

      it "assigns the specified commit for the view template" do
        perform_request
        assigns[:commit].should == @commit
      end
    end

    context "an invalid request" do
      before(:each) do
        @project = Project.make
        Commit.destroy_all
      end

      it "returns a status code of '404'" do
        perform_request
        response.code.should == '404'
      end
    end
  end

  describe "a GET to latest" do
    before(:each) do
      commit_count = 3
      @project = Project.make
      @commits = commit_count.times.map {Commit.make(:committed_at => 2.days.ago)}
      @commit = Commit.make
      @commits << @commit
      # Build out the commit hierarchy
      @commits.each_with_index do |commit, index|
        identifier = @commits[index+1] && @commits[index+1].identifier
        commit.child_identifiers = identifier || ""
      end
      @project.commits << @commits
    end

    def perform_request
      get :latest, :project_id => @project.public_key
    end

    context "a valid request" do
      it_should_behave_like "Any valid GET request to a specific commit"

      it "assigns the project's most recent commit for the view template" do
        perform_request
        assigns[:commit].should == @commit
      end
    end

    context "when the project does not have any commits yet" do
      before(:each) do
        @project.commits.destroy_all
      end

      it "sets the location header to nil" do
        perform_request
        response.headers['Location'].should == nil
      end

      it "returns a status code of '404 Not found'" do
        perform_request
        response.status.should == '404 Not Found'
      end

      it "renders the show view template" do
        perform_request
        response.should render_template("api/v1/commits/show.xml.haml")
      end
    end
  end
end
