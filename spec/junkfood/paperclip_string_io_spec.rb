require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'PaperclipStringIO' do

  it 'should be a subclass of StringIO' do
    io = Junkfood::PaperclipStringIo.new ''
    io.kind_of?(StringIO).should eql(true)
  end

  it 'should have the content_type attribute' do
    io = Junkfood::PaperclipStringIo.new ''
    io.respond_to? :content_type
  end

  it 'should have the original_filename attribute' do
    io = Junkfood::PaperclipStringIo.new ''
    io.respond_to? :original_filename
  end

  it 'should have default content_type attribute' do
    io = Junkfood::PaperclipStringIo.new ''
    io.content_type.should eql('application/octet-stream')
  end

  it 'should have default original_filename attribute' do
    io = Junkfood::PaperclipStringIo.new ''
    io.original_filename.should eql('unnamed')
  end

  it 'should be able to have overridden attributes' do
    filename = 'test.png'
    content_type = 'image/png'
    io = Junkfood::PaperclipStringIo.new(
      '',
      :content_type => content_type,
      :filename => filename)
    io.content_type.should eql(content_type)
    io.original_filename.should eql(filename)
  end
end
