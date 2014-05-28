require 'spec_helper'

feature 'User submits submission' do

  scenario 'Complete a basic submission' do
    metrics    = create_list :metric, 3
    submission = create :submission

    visit "/submissions/#{submission.id}"

    metrics.each do |metric|
      expect(page).to have_text metric.name
      find("label[title=\"Rate '#{metric.name}' a #{SubmissionMetric::VALID_RATINGS.sample}\"]").click
    end

    click_button 'Submit'

    submission.reload.should be_complete
  end

end
