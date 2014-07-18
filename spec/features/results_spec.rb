require 'spec_helper'

feature 'Viewing results' do
  before(:each) do
    # for now
    Timecop.travel(Time.now.at_beginning_of_week-2.weeks+3.days) do
      create_list :submission, 10
      create_list :completed_submission, 20
    end

    # for later
    Timecop.travel(Time.now.at_beginning_of_week-1.week+3.days) do
      create_list :submission, 10
      create_list :completed_submission, 5
    end
  end

  context 'Authenticated' do
    before(:each) { login_as create(:user), scope: :user }

    scenario 'View a complete result' do
      result = Result.new(source: Submission.all, start_date: Time.now.at_beginning_of_week - 2.weeks, period: 1.week)

      visit "/results/#{result.to_param}"

      page.should have_text "#{result.start_date.format_like 'August 4, 2014'}"

      Metric.all.pluck(:name).each do |name|
        page.should have_text name
      end
    end

    scenario 'View an empty result' do
      result = Result.new(source: Submission.all, start_date: Time.now.at_beginning_of_week - 1.year, period: 1.week)

      visit "/results/#{result.to_param}"

      page.should have_text 'No data.'

      Metric.all.pluck(:name).each do |name|
        page.should_not have_text name
      end
    end

    scenario 'View an incomplete result' do
      result = Result.new(source: Submission.all, start_date: Time.now.at_beginning_of_week - 1.week, period: 1.week)

      visit "/results/#{result.to_param}"

      page.should have_text 'In progress!'

      Metric.all.pluck(:name).each do |name|
        page.should_not have_text name
      end
    end
  end

  scenario 'Unauthenticated' do
    visit '/results'
    page.should have_text 'Sign in with your Google Account'
  end

end
