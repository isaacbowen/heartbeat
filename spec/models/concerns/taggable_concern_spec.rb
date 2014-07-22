require 'spec_helper'

describe TaggableConcern do

  [:user, :submission].each do |factory|
    describe '::tagged_with' do
      it 'should pull out things with the right tags' do
        create(factory, tags: %w(one two))
        create(factory, tags: %w(one three))

        factory.to_s.camelize.constantize.tagged_with(:two).size.should == 1
        factory.to_s.camelize.constantize.tagged_with(:one).size.should == 2
      end
    end

    describe '#tags_as_string=' do
      specify { build(factory, tags_as_string: '#enova #rnd').tags.should == %w(enova rnd) }
      specify { build(factory, tags_as_string: '#enova! #rnd?').tags.should == %w(enova rnd) }
      specify { build(factory, tags_as_string: '#eno^va #rnd').tags.should == %w(enova rnd) }
    end

    describe '#tags_as_string' do
      specify { build(factory, tags: %w(enova rnd)).tags_as_string.should == '#enova #rnd' }
      specify { build(factory, tags: %w(enova)).tags_as_string.should == '#enova' }
      specify { build(factory, tags: %w()).tags_as_string.should == '' }
    end
  end

end
