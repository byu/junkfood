require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'Adler32' do

  it 'should checksum Wikipedia example' do
    adler32 = Junkfood::Adler32.new('Wikipedia')
    adler32.digest.should eql(300286872)
  end

  it 'should checksum Wikipedia example using update' do
    adler32 = Junkfood::Adler32Pure.new
    adler32.update('Wikipedia').should eql(300286872)
    adler32.digest.should eql(300286872)
  end

end
