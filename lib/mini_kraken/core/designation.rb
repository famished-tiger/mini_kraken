# frozen_string_literal: true

module MiniKraken
  module Core
    # Wordnet definition: Identifying word or words by which someone or
    # something is called and classified or distinguished from others.
    # Mix-in module that contains factored code for managing named entries
    # in a vocabulary such as variables and variable references.
    module Designation
      # @return [String] User-defined name of the variable
      attr_reader :name

      def init_designation(aName)
        @name = valid_name(aName)
      end

      # @param voc [Vocabulary]
      # @return [Freshness]
      def freshness(voc)
        voc.freshness_ref(self)
      end

      # @param voc [Vocabulary]
      # @return [Boolean]
      def fresh?(voc)
        frsh = freshness(voc)
        frsh.degree == :fresh || frsh.degree == :bound
      end

      # @param voc [Vocabulary]
      # @return [Boolean]
      def bound?(voc)
        frsh = freshness(voc)
        frsh.degree == :bound
      end

      # @param voc [Vocabulary]
      # @return [Boolean]
      def ground?(voc)
        frsh = freshness(voc)
        frsh.degree == :bound
      end

      private

      def valid_name(aName)
        if aName.empty?
          raise StandardError, 'Variable name may not be empty.'
        end

        aName
      end
    end # class
  end # module
end # module
