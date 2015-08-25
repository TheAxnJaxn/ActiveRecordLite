Used Ruby's inflection and meta-programming to create an ActiveRecord Lite.

Active Record Lite:
- [X] Implement a ::my_attr_accessor macro for AR's attr_accessor setter/getter methods
- [X] Write a SQLObject class that interacts with the database to: return ::all, ::find, #insert, #update, and #save
- [X] Write a Searchable module that adds the ability to search with ::where
- [X] Write an Associatable module to mixin with SQLObject for belongs_to and has_many associations

Dependancies:
- Ruby
- Active Support
- RSpec for testing
- DBConnection & SQLite3

To do:
- [ ] Combine with Rails Lite
- [ ] Validator class with validation methods
- [ ] has_many :through (should handle both belongs_to => has_many and has_many => belongs_to)
- [ ] #includes that does pre-fetching
- [ ] #joins
