module Dynflow
  module ExecutionPlan::Steps
    class Abstract < Serializable
      include Algebrick::TypeCheck

      attr_reader :execution_plan_id, :id, :state, :action_class, :action_id, :world

      def initialize(execution_plan_id, id, state, action_class, action_id, world)
        @id                = id || raise(ArgumentError, 'missing id')
        @execution_plan_id = is_kind_of! execution_plan_id, String
        @world             = is_kind_of! world, World

        if state.is_a?(String) && STATES.map(&:to_s).include?(state)
          self.state = state.to_sym
        else
          self.state = state
        end

        is_kind_of! action_class, Class
        raise ArgumentError, 'action_class is not an child of Action' unless action_class < Action
        raise ArgumentError, 'action_class must not be phase' if action_class.phase?
        @action_class = action_class

        @action_id = action_id || raise(ArgumentError, 'missing action_id')
      end

      def phase
        raise NotImplementedError
      end

      def persistence
        world.persistence
      end

      STATES = Action::STATES

      def state=(state)
        raise "unknown state #{state}" unless STATES.include? state
        @state = state
      end

      def execute(*args)
        raise NotImplementedError
      end

      def to_hash
        { id:           id,
          state:        state,
          class:        self.class.to_s,
          action_class: action_class.to_s,
          action_id:    action_id }
      end

      protected

      def self.new_from_hash(hash, execution_plan_id, world)
        check_class_matching hash
        new execution_plan_id,
            hash[:id],
            hash[:state],
            hash[:action_class].constantize,
            hash[:action_id],
            world
      end

    end
  end
end
