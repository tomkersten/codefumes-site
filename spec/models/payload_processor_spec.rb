require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PayloadProcessor do
  describe "process!" do
    context "with a payload containing 3 commits" do
      before(:each) do
        @project = Project.make
        @content = {"commits"=>
                      [
                      {"author_email"    => "developer_one@example.com",
                       "author_name"     => "Developer One",
                       "committed_at"=>"Wed May 20 09:09:06 -0500 2009",
                       "short_message"=>"Last commit",
                       "authored_at"=>"Wed May 20 09:09:06 -0500 2009",
                       "identifier"=>"f3badd5624dfbc35176f0471261731e1b92ce957",
                       "message"=>"Last commit\n- 2nd line of commit message",
                       "committer_email" => "developer_one@example.com",
                       "committer_name"  => "Developer One",
                      },
                      {"author_email"    => "developer_one@example.com",
                       "author_name"     => "Developer One",
                       "committed_at"=>"Wed May 13 22:40:46 -0500 2009",
                       "short_message"=>"Second commit",
                       "authored_at"=>"Wed May 13 22:40:46 -0500 2009",
                       "identifier"=>"2debe9d1b2591d1face99fd49246fc952df38666",
                       "message"=>"Second commit",
                       "committer_email" => "developer_one@example.com",
                       "committer_name"  => "Developer One",
                      },
                      {"author_email"    => "developer_one@example.com",
                       "author_name"     => "Developer One",
                       "committed_at"    => "Wed May 13 22:26:13 -0500 2009",
                       "short_message"   => "Initial commit",
                       "authored_at"     => "Wed May 13 22:26:13 -0500 2009",
                       "identifier"      => "9aedb043a88b1e2e8c165a3791b9da4961d1dfa3",
                       "message"         => "Initial commit",
                       "committer_email" => "developer_one@example.com",
                       "committer_name"  => "Developer One"},
                       ]
                    }
        @payload = Payload.make(:project => @project, :content => @content)
      end

      context "when all commits are processed successfully" do
        it "creates a new commit for each entry in the payload" do
          lambda {
            PayloadProcessor.process!(@payload)
          }.should change(Commit, :count).by(3)
        end

        it "assigns the commits created to the same project the payload was associated with" do
          lambda {
            PayloadProcessor.process!(@payload)
          }.should change(@project.commits, :count).by(3)
        end

        it "marks the 'outcome' as 'Successful'"
      end

      context "when all commits are not processed successfully" do
        it "marks the 'outcome' as 'Unsuccessful'"
      end
    end
  end
end
