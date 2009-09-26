module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in webrat_steps.rb
  #
  def path_to(page_name)
    case page_name
      when /the (homepage|home page)/
        '/'
      when /the (sign up|signup) page/i
        signup_path
      when /the (sign in|signin|login) page/i
        login_path
      when /the project's short_uri page/i
        short_uri_path(@project)
      else
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
