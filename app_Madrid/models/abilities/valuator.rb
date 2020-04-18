module Abilities
  class Valuator
    include CanCan::Ability

    def initialize(user)
      can :read, SpendingProposal

      if Setting['feature.spending_proposal_features.valuation_allowed'].present?
        can [:update, :valuate], SpendingProposal
      end

      valuator = user.valuator

      can [:read], SpendingProposal

      can [:read, :update, :comment_valuation], Budget::Investment, id: valuator.assigned_investment_ids
      can [:valuate], Budget::Investment, { id: valuator.assigned_investment_ids, valuation_finished: false }
      cannot [:update, :valuate, :comment_valuation], Budget::Investment, budget: { phase: 'finished' }
    end
  end
end
