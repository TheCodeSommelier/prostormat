# ApplicationRecord serves as the base class for all models in the application,
# leveraging Rails' Active Record features. It is abstract, meaning it does not
# correspond to a table in the database itself but is inherited by other models.
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
