# encoding: utf-8
# Copyright 2010 Benjamin Yu <http://benjaminyu.org/>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'stringio'

module Junkfood

  ##
  # Adapter to save blobs of in-memory data into paperclip enabled
  # ActiveRecord models without requiring the use of temporary files.
  #
  # @example
  #
  #    class FaxDocument < ActiveRecord::Base
  #      has_attached_file :pdf
  #    end
  #
  #    def incoming_fax_handler()
  #      attachment = 'Blob of Faxed Data in PDF form'
  #      fax_number = '555-1234'
  #
  #      fax_document = FaxDocument.create(
  #        :caption => 'Look at this Document!',
  #        :pdf => PaperclipStringIo.new(
  #          attachment,
  #          :filename => "#{fax_number}.pdf",
  #          :content_type => 'application/pdf'))
  #    end
  #
  # @see http://rubygems.org/gems/paperclip
  #
  class PaperclipStringIo < StringIO
    attr_reader :original_filename, :content_type

    # Default filename
    DEFAULT_FILENAME = 'unnamed'

    # Default file content_type
    DEFAULT_CONTENT_TYPE = 'application/octet-stream'

    ##
    # @param string (String) blob of to save into paperclip.
    # @option options [String] :filename ('unnamed') set the filename
    #   component for the paperclip object.
    # @option options [String] :content_type ('application/octet-stream')
    #   set the paperclip object's mime content type.
    #
    def initialize(string, options={})
      super(string)
      @original_filename = options[:filename] || DEFAULT_FILENAME
      @content_type = options[:content_type] || DEFAULT_CONTENT_TYPE
    end
  end
end
