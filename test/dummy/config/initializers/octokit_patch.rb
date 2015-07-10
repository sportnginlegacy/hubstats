Octokit.configure do |c|
  c.connection_options[:ssl] = { :version => :TLSv1_2 }
end
