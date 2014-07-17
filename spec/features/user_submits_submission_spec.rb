require 'spec_helper'

feature 'User submits submission' do
  before(:each) { optional_metrics; required_metrics; submission }

  let(:optional_metrics) { create_list :metric, 3 }
  let(:required_metrics) { create_list :required_metric, 3 }
  let(:submission) { create :submission }

  scenario 'Complete a basic submission' do
    visit "/submissions/#{submission.id}"

    page.current_path.should == "/submissions/#{submission.id}/edit"

    (required_metrics + optional_metrics).each do |metric|
      page.should have_text metric.name
      find("label[data-original-title=\"Rate '#{metric.name}' a #{Heartbeat::VALID_RATINGS.sample}\"]").click
    end

    fill_in('submission[comments]', with: 'help!')

    click_button 'Submit'

    page.should have_content 'Thanks for your submission'

    page.current_path.should == "/submissions/#{submission.id}"

    submission.reload.should be_completed
    submission[:completed].should be_true
    submission[:completed_at].should_not be_nil
    submission.comments.should == 'help!'
    submission.submission_metrics.map(&:rating).all?(&:present?).should be_true
  end

end
