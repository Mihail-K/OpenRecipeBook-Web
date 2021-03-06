# frozen_string_literal: true

$app.before do
  book = Services::BookService.new
  pass if book.exists? || request.path_info == '/setup'

  redirect to('/setup')
end

$app.get '/setup' do
  book = Services::BookService.new

  if book.exists?
    redirect to('/recipes')
  else
    erb :setup, locals: { errors: {} }
  end
end

$app.post '/setup' do
  book     = Services::BookService.new
  contract = Contracts::SetupContract.new
  result   = contract.call(request.POST.fetch('setup'))

  if result.success?
    book.clone(**result.to_h)

    redirect to('/recipes')
  else
    erb :setup, locals: { errors: result.errors }
  end
end

$app.get '/recipes' do
  recipes = Repositories::RecipeRepository.new

  erb :'recipes/index', locals: { recipes: recipes.all }
end

$app.get '/recipes/search' do
  service = Services::SearchService.new
  query   = params['query']
  recipes = service.search(query: query)

  erb :'recipes/search', locals: { query: query, recipes: recipes }
end

$app.get '/recipes/:section/:slug' do
  recipes = Repositories::RecipeRepository.new
  recipe  = recipes.find(params['section'], params['slug'])

  erb :'recipes/show', locals: { recipe: recipe }
end

$app.get '/recipes/new' do
  erb :'recipes/new', locals: { recipe: Models::Recipe.empty, errors: {} }
end

$app.post '/recipes' do
  recipes  = Repositories::RecipeRepository.new
  contract = Contracts::RecipeContract.new
  result   = contract.call(request.POST.fetch('recipe'))

  if result.success?
    recipe = recipes.create(result.to_h)

    redirect to("/recipes/#{recipe.id}")
  else
    recipe = Models::Recipe.new(result.to_h)

    erb :'recipes/new', locals: { recipe: recipe, errors: result.errors }
  end
end

$app.get '/recipes/:section/:slug/edit' do
  recipes = Repositories::RecipeRepository.new
  recipe  = recipes.find(params['section'], params['slug'])

  erb :'recipes/edit', locals: { recipe: recipe, errors: {} }
end

$app.patch '/recipes/:section/:slug' do
  recipes  = Repositories::RecipeRepository.new
  contract = Contracts::RecipeContract.new
  recipe   = recipes.find(params['section'], params['slug'])
  result   = contract.call(request.POST.fetch('recipe'))

  if result.success?
    recipe = recipes.update(recipe, result.to_h)

    redirect to("/recipes/#{recipe.id}")
  else
    recipe = Models::Recipe.rebuild(recipe, result.to_h)

    erb :'recipes/edit', locals: { recipe: recipe, errors: result.errors }
  end
end

$app.get '/recipes/:section/:slug/delete' do
  recipes = Repositories::RecipeRepository.new
  recipe  = recipes.find(params['section'], params['slug'])

  erb :'recipes/delete', locals: { recipe: recipe }
end

$app.delete '/recipes/:section/:slug' do
  recipes = Repositories::RecipeRepository.new
  recipe  = recipes.find(params['section'], params['slug'])
  recipes.delete(recipe)

  redirect to('/recipes')
end

$app.get '/equipment' do
  repository = Repositories::EquipmentRepository.new
  equipment  = repository.all

  erb :'equipment/index', locals: { equipment: equipment }
end

$app.get '/equipment/:id' do
  repository = Repositories::EquipmentRepository.new
  equipment  = repository.find(params['id'])

  erb :'equipment/show', locals: { equipment: equipment }
end

$app.get '/ingredients' do
  repository  = Repositories::IngredientRepository.new
  ingredients = repository.all

  erb :'ingredients/index', locals: { ingredients: ingredients }
end

$app.get '/ingredients/new' do
  erb :'ingredients/new', locals: { ingredient: Models::Ingredient.empty, errors: {} }
end

$app.post '/ingredients' do
  contract   = Contracts::IngredientContract.new
  repository = Repositories::IngredientRepository.new
  result     = contract.call(request.POST.fetch('ingredient'))

  if result.success?
    ingredient = repository.create(result.to_h)

    redirect to("/ingredients/#{ingredient.id}")
  else
    ingredient = Models::Ingredient.new(result.to_h)

    erb :'ingredients/new', locals: { ingredient: ingredient, errors: result.errors.to_h }
  end
end

$app.get '/ingredients/:id/edit' do
  repository = Repositories::IngredientRepository.new
  ingredient = repository.find(params['id'])

  erb :'ingredients/edit', locals: { ingredient: ingredient, errors: {} }
end

$app.patch '/ingredients/:id' do
  contract   = Contracts::IngredientContract.new
  repository = Repositories::IngredientRepository.new
  ingredient = repository.find(params['id'])
  result     = contract.call(request.POST.fetch('ingredient'))

  if result.success?
    ingredient = repository.update(ingredient, result.to_h)

    redirect to("/ingredients/#{ingredient.id}")
  else
    ingredient = Models::Ingredient.rebuild(ingredient, result.to_h)

    erb :'ingredients/edit', locals: { ingredient: ingredient, errors: result.errors.to_h }
  end
end

$app.get '/ingredients/:id' do
  repository = Repositories::IngredientRepository.new
  ingredient = repository.find(params['id'])

  erb :'ingredients/show', locals: { ingredient: ingredient }
end
