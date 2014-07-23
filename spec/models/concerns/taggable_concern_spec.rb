require 'spec_helper'

describe TaggableConcern do

  [:user, :submission].each do |factory|
    describe factory do
      let(:klass) { factory.to_s.camelize.constantize }

      describe '::tagged_with' do
        it 'should pull out things with the right tags' do
          create(factory, tags: %w(one two))
          create(factory, tags: %w(one three))

          klass.tagged_with(:two).size.should == 1
          klass.tagged_with(:one).size.should == 2
        end
      end

      describe '::tags' do
        it 'should pull out the unique/sorted set of tags' do
          create(factory, tags: %w(one two))
          create(factory, tags: %w(one three))
          create(factory, tags: %w(one two four))

          klass.tags.should == [:one, :two, :three, :four].sort
          klass.tagged_with(:two).tags.should == [:one, :two, :four].sort
        end
      end

      describe '#tags_as_string=' do
        specify { build(factory, tags_as_string: '#enova #rnd').tags.should == [:enova, :rnd] }
        specify { build(factory, tags_as_string: '#enova! #rnd?').tags.should == [:enova, :rnd] }
        specify { build(factory, tags_as_string: '#eno^va #rnd').tags.should == [:enova, :rnd] }
      end

      describe '#tags_as_string' do
        specify { build(factory, tags: %w(enova rnd)).tags_as_string.should == '#enova #rnd' }
        specify { build(factory, tags: %w(enova)).tags_as_string.should == '#enova' }
        specify { build(factory, tags: %w()).tags_as_string.should == '' }
      end
    end
  end

end
