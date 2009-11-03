module CoreExtensions
end

Dir.glob(File.join("#{RAILS_ROOT}",'lib','core_extensions','**','*.rb')).sort.each{|file| require file}
