module CoreExtensions
  module ActiveRecord
  end
end

ActiveRecord::Base.send :include, CoreExtensions::ActiveRecord::Identifier
ActiveRecord::Base.send :include, CoreExtensions::ActiveRecord::AttributePrecedence
