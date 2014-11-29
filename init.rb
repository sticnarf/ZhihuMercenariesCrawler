# set id of seed answer here
seed_answer = 33495789

if File.exist?('data.db')
  print 'The database file already exists. Still continue? (Y/N) '
  input = gets
  exit unless input.strip.upcase == 'Y'
  File.delete('data.db')
end

require_relative 'db'

DB.create_table :users do
  primary_key :id
  String :identifier, index: true, unique: true
  String :name
  Fixnum :vote
  Fixnum :answer
  Fixnum :follower
  Float :value
  boolean :visited, default: false
  boolean :judgment
end

DB.create_table :answers do
  primary_key :id
  Fixnum :identifier, index: true, unique: true
  Fixnum :vote
  Fixnum :pollution
  boolean :visited, default: false
end

DB.create_table :users_answers do
  foreign_key :user_id, :users, key: :id, index: true
  foreign_key :answer_id, :answers, key: :id, index: true
  primary_key [:user_id, :answer_id]
end

DB.create_table :user_tasks do
  primary_key :id
  String :identifier, index: true, unique: true
  boolean :finished, default: false
end

DB.create_table :answer_tasks do
  primary_key :id
  Fixnum :identifier, index: true, unique: true
  boolean :finished, default: false
end

init

AnswerTask.create(identifier: seed_answer)