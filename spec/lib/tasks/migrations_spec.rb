require "rails_helper"

describe "Migration tasks" do
  describe "valuation_taggins" do
    let(:run_rake_task) do
      Rake::Task["migrations:valuation_taggings"].reenable
      Rake.application.invoke_task("migrations:valuation_taggings")
    end

    it "updates taggings" do
      valuation_tagging = create(:tagging, context: "valuation")
      another_valuation_tagging = create(:tagging, context: "valuation")
      valuation_tags_tagging = create(:tagging, context: "valuation_tags")
      tags_tagging = create(:tagging)

      run_rake_task

      expect(valuation_tagging.reload.context).to eq "valuation_tags"
      expect(another_valuation_tagging.reload.context).to eq "valuation_tags"
      expect(valuation_tags_tagging.reload.context).to eq "valuation_tags"
      expect(tags_tagging.reload.context).to eq "tags"
    end
  end

  describe "budget_admins_and_valuators" do
    let(:run_rake_task) do
      Rake::Task["migrations:budget_admins_and_valuators"].reenable
      Rake.application.invoke_task("migrations:budget_admins_and_valuators")
    end

    let(:old_budget) { create(:budget) }
    let(:current_budget) { create(:budget) }

    it "assigns administrators from existing investments" do
      harold = create(:administrator)
      john = create(:administrator)
      root = create(:administrator)

      create(:budget_investment, budget: old_budget, administrator: john)
      create(:budget_investment, budget: old_budget, administrator: harold)
      create(:budget_investment, budget: old_budget, administrator: nil)

      create(:budget_investment, budget: current_budget, administrator: root)

      run_rake_task

      expect(old_budget.administrators).to match_array [john, harold]
      expect(current_budget.administrators).to match_array [root]
    end

    it "assigns valuators from existing investments" do
      tyrion = create(:valuator)
      cersei = create(:valuator)
      jaime = create(:valuator)

      create(:budget_investment, budget: old_budget, valuators: [cersei])
      create(:budget_investment, budget: old_budget, valuators: [jaime, cersei])
      create(:budget_investment, budget: old_budget, valuators: [])

      create(:budget_investment, budget: current_budget, valuators: [tyrion, jaime])

      run_rake_task

      expect(old_budget.valuators).to match_array [cersei, jaime]
      expect(current_budget.valuators).to match_array [tyrion, jaime]
    end
  end
end
