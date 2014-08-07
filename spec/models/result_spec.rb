require 'spec_helper'

describe Result do

  let(:period) { 1.week }
  let(:start_date) { (1.week.ago + 1.day).to_date }

  [Submission, SubmissionMetric].each do |model|

    # get some data in there
    before(:each) do
      # heads up, this only makes sense for subs and their ilk
      Timecop.travel(start_date + 1.day) do
        create_list(:submission, 3)
        create_list(:completed_submission, 3)
      end

      User.where(id: User.first(3).map(&:id)).update_all(manager_user_id: create(:user).id)
      User.where(id: User.last(3).map(&:id)).update_all(manager_user_id: create(:user).id)
    end

    [:live, :cached].each do |mode|
      describe "for #{model.name} in #{mode} mode" do
        let(:source) { model.all }
        let(:subject) { Result.new source: source, period: period, start_date: start_date, mode: mode }
        let(:sample) { subject.sample }

        describe '#start_date' do
          it 'should default to the current week\'s start date' do
            Timecop.travel(Time.local(2008, 9, 1, 10, 5, 0)) do
              Result.new.start_date.should == Date.current.at_beginning_of_week
              Result.new(start_date: 1.day.ago).start_date.to_i.should == 1.day.ago.to_i
            end
          end
        end

        describe '#period' do
          it 'should default to 1.week' do
            Result.new.period.should == 1.week
            Result.new(period: 1.month).period.should == 1.month
          end
        end

        describe '#to_param' do
          it 'should be Ymd' do
            subject.to_param.should == start_date.strftime('%Y%m%d')
          end
        end

        describe '#cache_key' do
          it 'should change when a thing changes' do
            subject.cache_key.should_not be_nil

            cache_key = subject.cache_key

            create :submission, created_at: start_date + 1.day

            subject.reload
            subject.cache_key.should_not be_nil
            subject.cache_key.should_not == cache_key
          end
        end

        describe '#created_at' do
          it 'should be the min created at' do
            Timecop.travel(start_date + 1.hour) do
              create :submission
            end

            subject.created_at.should_not == subject.sample.map(&:created_at).max
            subject.created_at.should == subject.sample.map(&:created_at).min
            subject.created_at.to_i.should == (start_date + 1.hour).to_i
          end
        end

        describe '#updated_at' do
          it 'should be the max updated at' do
            Timecop.travel(start_date + 1.day + 1.hour) do
              create :submission
            end

            subject.updated_at.should_not == subject.sample.map(&:updated_at).min
            subject.updated_at.should == subject.sample.map(&:updated_at).max
            subject.updated_at.to_i.should == (start_date + 1.day + 1.hour).to_i
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

        [:empty?, :any?, :count, :size].each do |method_name|
          describe "##{method_name}" do
            it "should be sample.#{method_name}" do
              subject.stub(:sample) { double(method_name => 'foobar') }
              subject.send(method_name).should == 'foobar'
            end
          end
        end

        describe '#klass' do
          it 'should be the class' do
            subject.klass.should == model
          end
        end

        describe '#sample' do
          it 'should be the result of querying the source within the given period' do
            subject.sample.to_a.sort_by(&:id).should == subject.source.where('created_at >= ?', start_date.at_beginning_of_day).where('created_at <= ?', (start_date + period).at_end_of_day).to_a.sort_by(&:id)
          end
        end

        describe '#rating' do
          it 'should be the average of all ratings' do
            ratings = sample.select(&:completed?).map(&:rating)

            subject.rating.should == (ratings.sum.to_f / ratings.size).round(1)
          end
        end

        describe '#rating_counts' do
          it 'should be what is' do
            if model == Submission
              expect { subject.rating_counts }.to raise_exception NotImplementedError
            elsif model == SubmissionMetric
              subject.rating_counts.should == Hash[Heartbeat::VALID_RATINGS.map { |r| [r, sample.select(&:completed?).select { |s| s.rating == r }.size]}]
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
        it { should respond_to :unity }
        it { should respond_to :shortest_time_to_completion }

        describe '#comments' do
          it 'should be an array of Comments, sourced from the sample, sorted by the rating' do
            source.update_all comments: '', comments_public: false

            subs = source.sample(2)
            subs.each { |s| s.comments = 'foobar'; s.save! }

            subject.comments.size.should == 2
            subject.comments.map(&:class).uniq.should == [Comment]
            subject.comments.map { |c| c.source.rating }.map(&:to_f).should == subs.map(&:rating).map(&:to_f).sort.reverse
          end
        end

        describe '#public_comments' do
          it 'should be an array of public Comments, sourced from the sample' do
            source.update_all comments: '', comments_public: false

            subs = source.sample(2)
            subs.each { |s| s.comments = 'foobar'; s.save! }

            subs = source.sample(1)
            subs.each { |s| s.comments = 'foobar'; s.comments_public = true; s.save! }

            subject.public_comments.size.should == 1
            subject.public_comments.map(&:class).uniq.should == [Comment]
            subject.public_comments.all?(&:public?).should be_true
          end
        end

        describe '#private_comments' do
          it 'should be an array of public Comments, sourced from the sample' do
            source.update_all comments: '', comments_public: true

            subs = source.sample(5)
            subs.each { |s| s.comments = 'foobar'; s.save! }

            subs = source.sample(3)
            subs.each { |s| s.comments = 'foobar'; s.comments_public = false; s.save! }

            subject.private_comments.size.should == 3
            subject.private_comments.map(&:class).uniq.should == [Comment]
            subject.private_comments.all?(&:public?).should be_false
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

    describe 'modes vs cached' do
      let(:live_result) { Result.new source: model.all, period: period, start_date: start_date, mode: :live }
      let(:cached_result) { Result.new source: model.all, period: period, start_date: start_date, mode: :cached }

      # get some historical data in there
      before(:each) do
        Timecop.travel(start_date + 1.day - live_result.period) do
          create_list(:submission, 3)
          create_list(:completed_submission, 3)
        end
      end

      [:volatility, :unity, :representation, :delta, :rating_counts].each do |thing|
        it "should have the same #{thing}" do
          begin
            live_result.send(thing).should == cached_result.send(thing)
          rescue NotImplementedError
            # it's cool
          end
        end

        it "should have the same sparkline for #{thing}" do
          begin
            live_result.sparklines[thing].should == cached_result.sparklines[thing]
          rescue NotImplementedError
            # it's cool
          end
        end
      end
    end
  end

end
