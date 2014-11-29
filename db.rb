require 'sequel'

DB = Sequel.connect('sqlite://data.db')

def init
  eval(%Q{
    class User < Sequel::Model
      many_to_many :answers
    end

    class Answer < Sequel::Model
      many_to_many :users
    end

    class UserTask < Sequel::Model
    end

    class AnswerTask < Sequel::Model
    end
  })
end