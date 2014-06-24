require 'spec_helper'

describe Result do

  let(:period) { 1.week }
  let(:start_date) { (1.week.ago + 1.day).to_date }
  let(:sample) { subject.sample }

  [Submission, SubmissionMetric].each do |model|
    describe "for #{model.name}" do
      let(:source) { model.all }

      # get some data in there
      before(:each) do
        # heads up, this only makes sense for subs and their ilk
        create_list(:submission, 10, created_at: start_date + 1.day)
        create_list(:completed_submission, 10, created_at: start_date + 1.day)
      end

      subject do
        Result.new source: source, period: period, start_date: start_date
      end

      describe '#to_param' do
        it 'should be Ymd' do
          subject.to_param.should == start_date.strftime('%Y%m%d')
        end
      end

      describe '#complete?' do
        it 'should hinge at 50% on #representation' do
          subject.stub(:representation) { 0.2 }
          subject.should_not be_complete

          subject.stub(:representation) { 0.51 }
          subject.should be_complete
        end
      end

      [:empty?, :any?, :count, :size, :klass].each do |method_name|
        describe "##{method_name}" do
          it "should be sample.#{method_name}" do
            subject.stub(:sample) { double(method_name => 'foobar') }
            subject.send(method_name).should == 'foobar'
          end
        end
      end

      describe '#sample' do
        it 'should be the result of querying the source within the given period' do
          subject.sample.to_a.should == subject.source.where('created_at >= ?', start_date.at_beginning_of_day).where('created_at <= ?', (start_date + period).at_end_of_day).to_a
        end
      end

      describe '#rating' do
        it 'should be the average of all ratings' do
          ratings = sample.complete.map(&:rating)

          subject.rating.should == (ratings.sum.to_f / ratings.size).round(1)
        end
      end

      describe '#rating_counts' do
        it 'should be what is' do
          if model == Submission
            expect { subject.rating_counts }.to raise_exception NotImplementedError
          elsif model == SubmissionMetric
            subject.rating_counts.should == Hash[Heartbeat::VALID_RATINGS.map { |r| [r, sample.complete.where(rating: r).count]}]
          else
            raise NotImplementedError, "what am I supposed to do with a #{model}"
          end
        end
      end

      describe '#delta' do
        it 'should be the current rating minus the previous rating' do
          subject.stub(:previous) { double(rating: 3.0) }
          subject.stub(:rating) { 2.0 }

          subject.delta.should == -1.0
        end
      end

      describe '#representation' do
        it 'should be sample/population' do
          subject.representation.should == source.complete.count.to_f / source.count
        end
      end

      # these... I don't know how to test these.
      it { should respond_to :volatility }
      it { should respond_to :shortest_time_to_completion }

      describe '#comments' do
        it 'should be an array of Comments, sourced from the sample' do
          source.update_all comments: '', comments_public: false

          subs = source.sample(5)
          subs.each { |s| s.comments = 'foobar'; s.save! }

          subject.comments.size.should == 5
          subject.comments.map(&:class).uniq.should == [Comment]
        end
      end

      describe '#public_comments' do
        it 'should be an array of public Comments, sourced from the sample' do
          source.update_all comments: '', comments_public: false

          subs = source.sample(5)
          subs.each { |s| s.comments = 'foobar'; s.save! }

          subs = source.sample(3)
          subs.each { |s| s.comments = 'foobar'; s.comments_public = true; s.save! }

          subject.public_comments.size.should == 3
          subject.public_comments.map(&:class).uniq.should == [Comment]
          subject.public_comments.all?(&:public?).should be_true
        end
      end

      describe '#previous' do
        context 'with no data' do
          it 'should be nil' do
            subject.previous.should be_nil
          end
        end

        context 'with data' do
          it 'should not be nil' do
            Timecop.travel(start_date + period + 1.day) do
              create :submission
            end

            subject.next.should be_a Result
          end
        end
      end

      describe '#next' do
        context 'with no data' do
          it 'should be nil' do
            subject.next.should be_nil
          end
        end

        context 'with data' do
          it 'should not be nil' do
            Timecop.travel(start_date + period + 1.day) do
              create :submission
            end

            subject.next.should be_a Result
          end
        end
      end
    end
  end

end
