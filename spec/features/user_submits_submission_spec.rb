require 'spec_helper'

feature 'User submits submission' do
  before(:each) { optional_metrics; required_metrics }

  let(:optional_metrics) { create_list :metric, 3 }
  let(:required_metrics) { create_list :required_metric, 3 }

  scenario 'Complete a basic submission' do
    submission = create :submission

    visit "/submissions/#{submission.id}"

    required_metrics.each do |metric|
      page.should have_text metric.name
      find("label[title=\"Rate '#{metric.name}' a #{Heartbeat::VALID_RATINGS.sample}\"]").click
    end

    optional_metrics.each do |metric|
      find('.metric-name', text: metric.name, visible: false).should_not be_visible
      find('.metrics-list li', text: metric.name).click
      find('.metric-name', text: metric.name).should be_visible
      find("label[title=\"Rate '#{metric.name}' a #{Heartbeat::VALID_RATINGS.sample}\"]").click
    end

    fill_in('submission[comments]', with: 'help!')

    click_button 'Submit'

    submission.reload.should be_completed
    submission[:completed].should be_true
    submission[:completed_at].should_not be_nil
    submission.comments.should == 'help!'
  end

  scenario 'Comes back for round two and the last set of optional metrics are pre-opened' do
    user = create :user
    metrics = create_list(:metric, 3) + create_list(:required_metric, 3)

    Timecop.travel -1.day do
      create :completed_submission, user: user
    end

    submission = create :submission, user: user

    visit "/submissions/#{submission.id}"

    optional_metrics.each do |metric|
      find('.metric-name', text: metric.name, visible: false).should be_visible
    end
  end

end
