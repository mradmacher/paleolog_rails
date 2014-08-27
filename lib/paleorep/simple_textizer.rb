require_relative 'textizer'

module Paleorep
  class SimpleTextizer
    include Paleorep::Textizer

    def textize(object)
      object.to_s
    end
  end
end

