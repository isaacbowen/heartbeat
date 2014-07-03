FactoryGirl.define do
  factory :submission_reminder do
    submission
    from 'ibowen@enova.com'
    medium 'email'
    subject 'asdf'
    template 'sup {{submission.url}}'
  end
end
