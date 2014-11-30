require 'capybara'
require 'capybara/webkit'
require_relative 'db'

Capybara.default_driver = :webkit
$account_info = {
  email: 'c312417@trbvm.com',
  password: 'passw0rd'
}

init

class UserTask
  include Capybara::DSL
  
  def work
    retried = 0
    begin
      if retried > 1
        self.finished = true
        save
        return
      end
      puts "Start analyzing user #{identifier}"
      visit "http://www.zhihu.com/people/#{identifier}"
      name = find(".zm-profile-header-main .name").text
      vote = find(".zm-profile-header-user-agree strong").text.to_i
      follower = all(".zm-profile-side-following strong").last.text.to_i
      answer = all(".profile-navbar .num")[1].text.to_i
      # the argument in the formula below can be modified
      value = follower / (vote**1.5 + 1)
      judgment = true if value > 1
      User.create(name: name, vote: vote, follower: follower, answer: answer,
                  value: value, judgment: judgment, visited: true, identifier: identifier)
      if judgment
        all(".js-signin-noauth").each do |login|
          login.click
          fill_in 'email', with: $account_info[:email]
          fill_in 'password', with: $account_info[:password]
          find("#js-sign-flow input[type='submit']").click
        end
        # the max time to click 'show more'
        3.times do
          button = all('.zu-button-more')[0]
          break if button.nil?
          begin
            button.click
            sleep 0.1
          rescue Capybara::Webkit::NodeNotAttachedError => e
            sleep 0.1
            button = all('.zu-button-more')[0]
            break if button.nil?
            retry
          end
        end
        all('#zh-profile-activity-page-list .zm-profile-section-item.zm-item').each do |activity|
          if activity['data-type'] == 'a'
            if /\/answer\/(?<answer_id>[\w-]*)\z/ =~ activity.find('a.question_link')[:href]
              if Answer.where(identifier: answer_id).count == 0 and AnswerTask.where(identifier: answer_id).count == 0
                AnswerTask.create(identifier: answer_id)
                puts "Added task to analyze answer #{answer_id}"
              end
            end
          end
        end
      end
      self.finished = true
      save
    rescue
      retried += 1
      retry
    end
  end
end

class AnswerTask
  include Capybara::DSL
  
  def work
    puts "Start analyzing answer #{identifier}"
    visit "http://www.zhihu.com/answer/#{identifier}"
    more_button = all('#zh-question-answer-wrap a.more')[0]
    more_button.click if more_button
    sleep 0.05 while all('#zh-question-answer-wrap a.more').count > 0
    all('#zh-question-answer-wrap .zm-item-vote-info span.voters a').each do |voter|
      if /\/people\/(?<user_id>[\w-]*)\z/ =~ voter[:href]
        if User.where(identifier: user_id).count == 0 and UserTask.where(identifier: user_id).count == 0
          UserTask.create(identifier: user_id)
          puts "Added task to analyze user #{user_id}"
        end
      end
    end
    self.finished = true
    save
  end
end

tasks = ([UserTask] * 99 + [AnswerTask])

loop do
  tasks.sample.where(:finished => false).limit(10).each do |task|
    task.work
  end
end

