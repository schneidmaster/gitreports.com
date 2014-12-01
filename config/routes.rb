GitReports::Application.routes.draw do

  root 'pages#home'

  # Pages
  get '/profile', to: 'pages#profile', as: 'profile'
  get '/tutorial', to: 'pages#tutorial', as: 'tutorial'
  get '/about', to: 'pages#about', as: 'about'

  # Authentication routes
  get '/login', to: 'authentications#login', as: 'login'
  get '/github_callback', to: 'authentications#callback'
  get '/logout', to: 'authentications#logout', as: 'logout'
  get '/login_rate_limited', to: 'authentications#login_rate_limited', as: 'login_rate_limited'

  # Repository routes
  get '/issue/:username/:repositoryname', to: 'repositories#repository', as: 'repository_public', repositoryname: /[^\/]+/
  post '/issue/:username/:repositoryname', to: 'repositories#repository_submit', repositoryname: /[^\/]+/
  get '/issue/:username/:repositoryname/submitted', to: 'repositories#repository_submitted', as: 'repository_submitted', repositoryname: /[^\/]+/
  get '/repository/manage/:id', to: 'repositories#repository_show', as: 'repository'
  get '/repository/manage/:id/edit', to: 'repositories#repository_edit', as: 'repository_edit'
  patch '/repository/manage/:id', to: 'repositories#repository_update', as: 'repository_update'
  post '/repository/manage/:id/activate', to: 'repositories#repository_activate', as: 'repository_activate'
  post '/repository/manage/:id/deactivate', to: 'repositories#repository_deactivate', as: 'repository_deactivate'
  get '/load_status', to: 'repositories#load_status'

end
