# frozen_string_literal: true

module Components
  class RecipeFormComponent < BaseComponent
    self.template_file = root.join('recipe_form_component.erb')

    include Helpers::FormMethod

    # @param recipe [Models::Recipe]
    # @param equipment_repository [Repositories::EquipmentRepository]
    # @param errors [Hash]
    def initialize(recipe:, sections:, errors: {})
      @recipe   = recipe
      @sections = sections
      @errors   = errors
    end

    # @return [String]
    def http_action
      @recipe.id ? "/recipes/#{@recipe.id}" : '/recipes'
    end

    def cancel_path
      @recipe.id ? "/recipes/#{@recipe.id}" : '/recipes'
    end
  end
end
