def path_to(page_name)
  case page_name
  when /the (homepage|home page)/i
    root_path
  when /the (sign up|signup) page/i
    signup_path
  when /the (sign in|signin|login) page/i
    login_path
  else
    raise "Can't find mapping from \"#{page_name}\" to a path."
  end
end
