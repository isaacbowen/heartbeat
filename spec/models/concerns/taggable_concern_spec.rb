require 'spec_helper'

describe TaggableConcern do

  [:user, :submission].each do |factory|
    describe factory do
      let(:klass) { factory.to_s.camelize.constantize }

      describe 'class' do
        before(:each) do
          create(factory, tags: %w(one two))
          create(factory, tags: %w(one three))
          create(factory, tags: %w(one two four))
        end

        describe '#tagged_with' do
          it 'should pull out things with the right tags' do
            klass.tagged_with(:two).size.should == 2
            klass.tagged_with(:one).size.should == 3
          end

          it 'should be able to handle multiple tags' do
            klass.tagged_with(:one, :two).size.should == 2
            klass.tagged_with(:one, :two, :four).size.should == 1
            klass.tagged_with(:one, :two, :three).size.should == 0
          end
        end

        describe '#tags' do
          it 'should pull out the unique/sorted set of tags' do
            klass.tags.should == [:one, :two, :three, :four].sort
            klass.tagged_with(:two).tags.should == [:one, :two, :four].sort
          end
        end

        describe '#tags_and_counts' do
          it 'should pull out the tags, and their counts' do
            klass.tags_and_counts.should == {
              one: 3,
              two: 2,
              three: 1,
              four: 1,
            }
          end
        end
      end

      describe '#tags_as_string=' do
        specify { build(factory, tags_as_string: '#enova #rnd').tags.should == ['enova', 'rnd'] }
        specify { build(factory, tags_as_string: '#enova! #rnd?').tags.should == ['enova', 'rnd'] }
        specify { build(factory, tags_as_string: '#eno^va #rnd').tags.should == ['enova', 'rnd'] }
      end

      describe '#tags_as_string' do
        specify { build(factory, tags: %w(enova rnd)).tags_as_string.should == '#enova #rnd' }
        specify { build(factory, tags: %w(enova)).tags_as_string.should == '#enova' }
        specify { build(factory, tags: %w()).tags_as_string.should == '' }
      end

      describe '#suggested_tags' do
        it 'should suggest tags present' do
          create factory, tags: %w(trolls rnd)
          create factory, tags: %w(trolls rnd baz)
          create factory, tags: %w(rnd trogdor foo)
          create factory, tags: %w(rnd trogdor foo)
          create factory, tags: %w(rnd trogdor foo)
          create factory, tags: %w(rnd trogdor baz)
          create factory, tags: %w(rnd trogdor bar)
          create factory, tags: %w(rnd trogdor bar)

          build(factory, tags: %w(rnd trogdor)).suggested_tags.should == ['foo', 'bar', 'baz']
          build(factory, tags: %w(rnd trolls)).suggested_tags.should == ['baz']
        end

        it 'should return nothin if we have zero or one tags' do
          create factory, tags: %w(trolls rnd)
          create factory, tags: %w(trogdor rnd baz)
          build(factory, tags: %w(rnd)).suggested_tags.should == []
        end
      end
    end
  end

end
