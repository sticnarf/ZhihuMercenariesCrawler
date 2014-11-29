seed_answer = 33495789

if File.exist?('data.db')
  print 'The database file already exists. Still continue? (Y/N) '
  input = gets
  exit unless input.strip.upcase == 'Y'
  File.delete('data.db')
end

require './db.rb'

DB.create_table :users do
  primary_key :id
  String :identifier, index: true
  Fixnum :praise
  Fixnum :answer
  Fixnum :follower
  Float :possibility
  boolean :visited, default: false
  boolean :judgment
end

DB.create_table :answers do
  primary_key :id
  Fixnum :identifier, index: true
  Fixnum :praise
  Fixnum :pollution
  boolean :visited, default: false
  boolean :judgment
end

DB.create_table :users_answers do
  foreign_key :user_id, :users, key: :id, index: true
  foreign_key :answer_id, :answers, key: :id, index: true
  primary_key [:user_id, :answer_id]
end

DB.create_table :user_tasks do
  primary_key :id
  String :identifier, index: true
  boolean :finished, default: false
end

DB.create_table :answer_tasks do
  primary_key :id
  Fixnum :identifier, index: true
  boolean :finished, default: false
end

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

AnswerTask.create(:identifier => seed_answer)