# frozen_string_literal: true

require 'set'
require_relative 'cons_cell'

module MiniKraken
  module Composite
    # Factory class.
    # Purpose: to create an enumerator specialized in the visit of cons cells.
    class ConsCellVisitor
      # Build a depth-first in-order expression tree visitor.
      # The visitor is implemented as an Enumerator.
      # The enumerator returns couples of the form: [:car or :cdr or :nil, visitee]
      # [anExpr] the term to visit.
      # @param aCell [ConsCell]
      # @return [Fiber]
      def self.df_visitor(aCell)
        first = aCell	# The visit will start from the provided cons cell
        visitor = Fiber.new do |skipping|
          # Initialization part: will run once
          visitees = Set.new # Keep track of the conscell already visited
          visit_stack = first.nil? ? [] : [[:car, first]] # The LIFO queue of cells to visit

          until visit_stack.empty?	# Traversal part (as a loop)
            to_swap = false
            side, cell = visit_stack.pop
            next if visitees.include?(cell)

            visitees << cell

            skip_children = Fiber.yield [side, cell]
            # require 'debug' if skip_children
            next if skip_children || skipping

            skipping = false
            case cell.car
              when ConsCell
                visit_stack.push([:car, cell.car])
                to_swap = true
              else
                Fiber.yield [:car, cell.car]
            end

            case cell.cdr
              when ConsCell
                if to_swap
                  visit_stack.insert(-2, [:cdr, cell.cdr])
                else
                  visit_stack.push([:cdr, cell.cdr])
                end
              else
                Fiber.yield [:cdr, cell.cdr]
            end
          end

          # Send stop mark
          Fiber.yield [:stop, nil]
        end

=begin
        visitor = Enumerator.new do |requester|	# requester argument is a Yielder
          # Initialization part: will run once
          visitees = Set.new # Keep track of the conscell already visited
          visit_stack = first.nil? ? [] : [[ :car, first ]] # The LIFO queue of cells to visit

          until visit_stack.empty?	# Traversal part (as a loop)
            to_swap = false
            side, cell = visit_stack.pop()
            next if visitees.include?(cell)

            requester << [side, cell]
            case cell.car
              when ConsCell
                visit_stack.push([:car, cell.car])
                to_swap = true
              else
                requester << [:car, cell.car]
            end

            case cell.cdr
              when ConsCell
                if to_swap
                  visit_stack.insert(-2, [:cdr, cell.cdr])
                else
                  visit_stack.push([:cdr, cell.cdr])
                end
              else
                requester << [:cdr, cell.cdr]
            end

            visitees << cell
          end

          # Send stop mark
          requester << [:stop, nil]
        end
=end
        return visitor
      end
    end # class
  end # module
end # module
